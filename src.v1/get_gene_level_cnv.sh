#!/bin/bash
## get gene-level copy number values
## modified from 

detectDir=$1
scriptDir=$2
inputDir=$3
outputPath=$4
genelevelFile=$5
version=$6
geneBedFile=$7
batchName=$8

cd ${detectDir}
ls *.CNV | while read file; do
	sample=$(echo $file | cut -f1 -d'.')
	echo $sample
#	sed '1d' $file | cut -f1,2,3,9 | bedtools intersect -loj -a ${geneBedFile} -b - | awk '$8!="."'  | python ${scriptDir}"gene_segment_overlap.py" > ${outputPath}$sample.gene_level.log2.seg
	sed '1d' $file | cut -f1,2,3,9 | bedtools intersect -loj -a ${geneBedFile} -b - | python ${scriptDir}"gene_segment_overlap.py" > ${outputPath}$sample.gene_level.log2.seg
done

ls *.CNV | cut -f1 -d'.' > ${outputPath}samples.txt
cd ${outputPath}
genelevelOut=${genelevelFile}"."${batchName}".v"${version}".tsv"
echo gene > ${genelevelOut}
cut -f1 $(head -1 samples.txt).gene_level.log2.seg >> ${genelevelOut}
cat samples.txt | while read sample; do
	echo ${sample}
	echo $sample > smp
	cut -f5 $sample.gene_level.log2.seg >> smp
	paste ${genelevelOut} smp > tmp2
	mv -f tmp2 ${genelevelOut}
	rm -f smp
done
