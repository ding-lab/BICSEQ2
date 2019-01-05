#!/bin/bash

inputDir=$1
bamMapGit=$2
mappabilityDir=$3
bicseq2normLink=$4
bicseq2segLink=$5
mappabilityPrefix=$6
refDir=$7
refFile=$8
readLength=$9
genomeBuild=${10}
fastaLink=${11}
bamMapDir=${12}
geneAnnoGFF3Link=${13}
geneAnnoGFF3File=${14}
geneAnnoBedFile=${15}

cp chromosomes.txt ${inputDir}
cd ${inputDir}

## get the most updated version of BAM map
if [ -d ${bamMapDir} ]; then
	cd ${bamMapDir}
	git pull 
	cd ..
else
	git clone --recursive ${bamMapGit}
fi

wget ${bicseq2normLink}
tar -xzf NBICseq-norm_v0.2.4.tar.gz

wget ${bicseq2segLink}
tar -xzf NBICseq-seg_v0.7.2.tar.gz

cp -r /diskmnt/Projects/Users/qgao/Tools/BICSeq2/samtools-0.1.7a_getUnique-0.1.3 .
## get and unzip BIC-seq2 modules

## get the gene annotation bed file
if [ -s ${inputDir}${geneAnnoBedFile} ]
then
        echo "gene annotation bed file is available!"
else
        echo "gene annotation bed file is being generated!"
        if [ -s ${inputDir}${geneAnnoGFF3File} ]
        then
                echo "gene annotation GFF3 file is available"
        else
                echo "gene annotation GFF3 file is being copied!"
                cd ${inputDir}
                wget ${geneAnnoGFF3Link}
                gunzip ${geneAnnoGFF3File}.gz
        fi
        cat ${inputDir}${geneAnnoGFF3File} | awk '$3=="gene"' | grep protein_coding | convert2bed -i gff - | cut -f 1,2,3,10 | awk -F ';|\\t' '{print $1,$2,$3,$7}' | awk -F ' |\\=' '{print $1,$2,$3,$5}' OFS='\t' > ${inputDir}${geneAnnoBedFile}
fi

## get and split and reference fasta file
if [ -s ${inputDir}${refFile} ]
then
	echo "reference fasta file is available!"
else
	cp ${refDir}${refFile} ${inputDir}${refFile}
fi

if [ -s ${fastaDir}chr20.fa ]
then
	echo "per chromosome fasta file is available!"
else
	echo "per chromosome fasta file is being copied!"
	cd ${inputDir}
	mkdir -p ${genomeBuild}
	cd ${genomeBuild}
	cat ../chromosomes.txt | while read chr; do
		if [ -s ${fastaDir}"chr"${chr}.fa ]
		then
			echo "per chromosome fasta file is available!"
		else
			if [ -s ${fastaDir}"chr"${chr}.fa.gz ]
				echo ${fastaDir}"chr"${chr}".fa.gz is available!"
			else
				wget ${fastaLink}"chr"${chr}.fa.gz
			fi
			gunzip ${fastaDir}"chr"${chr}.fa.gz
		fi
	done
fi

## get the mappability file
if [ -s ${mappabilityDir}${mappabilityPrefix}.chr20.txt ]
then
	echo "mappability file available!"
else
	cd ${inputDir}
	if [ -s ${inputDir}${refFile}.gem ]
	then
		echo "${refFile}.gem is available!"
	else
		gem-indexer -i ${inputDir}${refFile} -o ${refFile} -T 8
	fi

	if [ -s ${inputDir}${refFile}.${readLength}mer.mappability ]
	then
		echo "${inputDir}${refFile}.${readLength}mer.mappability is available!"
	else
		## this step needs a lot of CPU to run it fast enough so that not to be killed
		gem-mappability -m 2 -I ${refFile}.gem -l ${readLength} -o ${refFile}.${readLength}mer -T 80 &> ${refFile}.${readLength}mer.mappability.log
	fi

	if [ -s ${refFile}.${readLength}mer.wig ]
	then
		echo "${refFile}.${readLength}mer.wig is available!"
	else
		gem-2-wig -I ${refFile}.gem -i ${inputDir}${refFile}.${readLength}mer.mappability -o ${refFile}.${readLength}mer
		awk -F ' ' '{print $1, $3}' ${refFile}.${readLength}mer.sizes | grep -v gi > ${refFile}.${readLength}mer.sizes.cut
		## cut the wig file starting from the line containing CMV
	fi

	if [ -s ${refFile}.${readLength}mer.bw ]
	then
		echo "${refFile}.${readLength}mer.bw is available!"
	else
		wigToBigWig ${refFile}.${readLength}mer.wig.cut  ${refFile}.${readLength}mer.sizes.cut ${refFile}.${readLength}mer.bw
	fi

	if [ -s ${refFile}.${readLength}mer.bedGraph ]
	then
		echo "${refFile}.${readLength}mer.bedGraph is available!"
	else
		bigWigToBedGraph ${refFile}.${readLength}mer.bw  ${refFile}.${readLength}mer.bedGraph
	fi

	if [ -s ${refFile}.${readLength}mer.bed ]
	then
		echo "${refFile}.${readLength}mer.bed is available!"
	else
		mkdir -p ${refFile}.${readLength}mer
		cd ${refFile}.${readLength}mer
		while read chr; do
			grep ${chr} ../${refFile}.${readLength}mer.bedGraph | awk '$4==1 {print $2,$3}' > ${refFile}.${readLength}mer.${chr}.txt 
		done<../chromosomes.txt
		# bedGraphTobed ${refFile}.${readLength}mer.bedGraph ${refFile}.${readLength}mer.bed 1 ${refFile} ${refFile}.${readLength}mer.uniq.bed
	fi
fi
