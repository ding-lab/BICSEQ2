#!/bin/bash

## the name of the master directory holding inputs, outputs and processing codes
toolName="BICSEQ2"
## the name of the batch
batchName="BICSEQ2.UCEC.hg38.121"
## the name the directory holding the processing code
toolDirName=${toolName}"."${batchName}
toolDirName="BICSEQ2.UCEC.hg38.121"
## the path to the master directory
mainRunDir="/diskmnt/Projects/CPTAC3CNV/"${toolName}"/"
## the path to the directory hold current scripts
scriptDir=${mainRunDir}${toolDirName}"/"
## the path to the inputs directory
inputDir=${mainRunDir}"inputs/"
mkdir -p ${inputDir}
## the path to the log directory
logDir=${mainRunDir}"logs/"
mkdir -p ${logDir}
## the path to the output directory
outputDir=${mainRunDir}"outputs/"
mkdir -p ${outputDir}
outputDir_batchName=${outputDir}${batchName}"/"
mkdir -p ${outputDir_batchName}
## the link to the BIC-seq2 norm module
bicseq2normLink="http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz"
## the link to the BIC-seq2 seg module
bicseq2segLink="http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz"
## the link to CPTAC3 catalog BAM map git hub
bamMapGit="https://github.com/ding-lab/CPTAC3.catalog.git"
## the path to the directory holding the manifest for BAM files
clusterName="katmai"
bamMapPath=${inputDir}"CPTAC3.catalog/"${clusterName}".BamMap.dat"
#bamMapPath="/gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs/CPTAC3.catalog/"${clusterName}".BamMap.dat"
#bamMapPath="/home/mwyczalk_test/Projects/CPTAC3/import/import.CPTAC3.UCEC.hg38.all/dat/CPTAC3.UCEC.WGS.hg38.all.BamMap.dat"
#bamMapPath="/home/mwyczalk_test/Projects/CPTAC3/import/import.CPTAC3.UCEC.hg38.all/dat/UCEC.WGS.hg38.all.BamMap.dat"
#bamMapPath=${inputDir}UCEC.WGS.hg38.all.BamMap.dat
## the path to the samtools helper script
samtoolsPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"
## the path to the BICseq2-norm perl script
normplPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/NBICseq-norm_v0.2.4/NBICseq-norm.pl"
## the path to the BICseq2-seg perl script
segplPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/NBICseq-seg_v0.7.2/NBICseq-seg.pl"
## the path to the mappability file
mappabilityDir="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/"
## the file prefix for the gene-level CNV report
genelevelFile="gene_level_CNV"
## the name of the processing version
version=1.2
## the type of the BAM files we are using
bamType="WGS"
## the directory to gemtools binary
refDir="/diskmnt/Datasets/Reference/GRCh38.d1.vd1/"
refFile="GRCh38.d1.vd1.fa"
## the length of the read
readLength=150
## the prefix of mappability file
mappabilityPrefix=${refFile}.${readLength}mer
## the genome build
genomeBuild=hg38
fastaLink="http://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/"
fastaDir=${inputDir}${genomeBuild}"/"
mkdir -p ${fastaDir}
## the gene annotation bed file
geneBedFile="/diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs/gencode.v29.annotation.hg38.p12.bed"
geneBedFile=${inputDir}"ucsc_refseq_hg38_all_fields_20180629.txStartEnd.dedup.bed"
#bash -c 'source activate bicseq2'

## get the list of samples
cancerType=UCEC
grep ${genomeBuild} ${bamMapPath} | grep ${cancerType} | grep ${bamType} | cut -f 2 | sort | uniq> sample.txt

if [ -s sample.txt ]
then
	wc sample.txt
else
	echo "sample list cannot be extracted from BAM map!"
	exit
fi


## get dependencies
step="get_dependencies"
cm="bash ${step}.sh ${inputDir} ${bamMapGit} ${mappabilityDir} ${bicseq2normLink} ${bicseq2segLink} ${mappabilityPrefix} ${refDir} ${refFile} ${readLength} ${genomeBuild} ${fastaLink} ${fastaDir}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}

## get unique reads
step="run_uniq"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${bamMapPath} ${samtoolsPath} ${outputPath} ${bamType} ${genomeBuild} &"
echo ${cm}

## get unique reads
seqDir=${outputPath}
step="run_norm"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${bamMapPath} ${normplPath} ${outputPath} ${fastaDir} ${mappabilityDir} ${seqDir} ${mappabilityPrefix} >&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}

## get unique reads
normDir=${outputPath}
step="run_detect"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${bamMapPath} ${segplPath} ${outputPath} ${fastaDir} ${mappabilityDir} ${normDir}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}

## get unique reads
detectDir=${outputPath}"lambda3/"
step="get_gene_level_cnv"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${detectDir} ${scriptDir} ${inputDir} ${outputPath} ${genelevelFile} ${version} ${geneBedFile} ${batchName}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}