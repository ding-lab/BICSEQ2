#!/bin/bash

touch main_config.txt > main_config.txt
## the name of the master directory holding inputs, outputs and processing codes
toolName="BICSEQ2"
echo "toolName=${toolName}" >> main_config.txt
## the name of the batch
batchName="LUAD.b5_6"
echo "batchName=${batchName}" >> main_config.txt
## the name the directory holding the processing code
toolDirName=${toolName}"."${batchName}
echo "toolDirName=${toolDirName}" >> main_config.txt
## the path to the master directory
mainRunDir="/gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/"${toolName}"/"
echo "mainRunDir=${mainRunDir}" >> main_config.txt
## the path to the directory hold current scripts
scriptDir=${mainRunDir}${toolDirName}"/"
echo "scriptDir=${scriptDir}" >> main_config.txt
## the path to the inputs directory
inputDir=${mainRunDir}"inputs/"
mkdir -p ${inputDir}
echo "inputDir=${inputDir}" >> main_config.txt
## the path to the log directory
logDir=${mainRunDir}"logs/"
mkdir -p ${logDir}
echo "logDir=${logDir}" >> main_config.txt
## the path to the output directory
outputDir=${mainRunDir}"outputs/"
mkdir -p ${outputDir}
echo "outputDir=${outputDir}" >> main_config.txt
outputDir_batchName=${outputDir}${batchName}"/"
mkdir -p ${outputDir_batchName}
echo "outputDir_batchName=${outputDir_batchName}" >> main_config.txt
## the link to the modified samtools
samtoolsLink="http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz"
## the link to the BIC-seq2 norm module
bicseq2normLink="http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz"
## the link to the BIC-seq2 seg module
bicseq2segLink="http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz"
## the link to CPTAC3 catalog BAM map git hub
bamMapGit="https://github.com/ding-lab/CPTAC3.catalog.git"
## the path to the directory holding the manifest for BAM files
clusterName="MGI"
bamMapPath=${inputDir}"CPTAC3.catalog/"${clusterName}".BamMap.dat"
echo "bamMapPath=${bamMapPath}" >> main_config.txt
bamMapDir=${inputDir}"CPTAC3.catalog/"
## the path to the samtools helper script
samtoolsPath=${inputDir}"samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"
echo "samtoolsPath=${samtoolsPath}" >> main_config.txt
## the path to the BICseq2-norm perl script
normplPath=${inputDir}"NBICseq-norm_v0.2.4/NBICseq-norm.pl"
echo "normplPath=${normplPath}" >> main_config.txt
## the path to the BICseq2-seg perl script
segplPath=${inputDir}"NBICseq-seg_v0.7.2/NBICseq-seg.pl"
echo "segplPath=${segplPath}" >> main_config.txt
## the path to the mappability file
mappabilityDir=${inputDir}"GRCh38.d1.vd1.fa.150mer/"
echo "mappabilityDir=${mappabilityDir}" >> main_config.txt
## the file prefix for the gene-level CNV report
genelevelFile="gene_level_CNV"
## the name of the processing version
version=1.1
## the type of the BAM files we are using
bamType="WGS"
echo "bamType=${bamType}" >> main_config.txt
## the directory to gemtools binary
refDir="/diskmnt/Datasets/Reference/GRCh38.d1.vd1/"
echo "refDir=${refDir}" >> main_config.txt
refFile="GRCh38.d1.vd1.fa"
echo "refFile=${refFile}" >> main_config.txt
## the length of the read
readLength=150
echo "readLength=${readLength}" >> main_config.txt
## the prefix of mappability file
mappabilityPrefix=${refFile}.${readLength}mer
echo "mappabilityPrefix=${mappabilityPrefix}" >> main_config.txt
## the genome build
genomeBuild=hg38
echo "genomeBuild=${genomeBuild}" >> main_config.txt
## the link to hg38 reference fasta files
fastaLink="http://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/"
fastaDir=${inputDir}${genomeBuild}"/"
mkdir -p ${fastaDir}
echo "fastaDir=${fastaDir}" >> main_config.txt
## the name of the docker image
dockerImage="yigewu/bicseq2:v2"
## the name of the cancer type
cancerType=LUAD
echo "cancerType=${cancerType}" >>  main_config.txt

## get the list of samples
grep ${genomeBuild} ${bamMapPath} | grep ${cancerType} | grep ${bamType} | cut -f 2 | sort | uniq> sample.txt

if [ -s sample.txt ]
then
	wc sample.txt
else
	echo "sample list cannot be extracted from BAM map!"
	exit
fi

## get the step name
step=$1

## get dependencies
#cm="bash ${step}.sh ${inputDir} ${bamMapGit} ${mappabilityDir} ${bicseq2normLink} ${bicseq2segLink} ${mappabilityPrefix} ${refDir} ${refFile} ${readLength} ${genomeBuild} ${fastaLink} ${fastaDir} ${bamMapDir}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
#echo ${cm}

## get unique reads
#step="run_uniq"
if [ "${step}" == "run_uniq" ]
then
	outputPath=${outputDir_batchName}${step}"/"
	mkdir -p ${outputPath}
	echo "outputPath=${outputPath}" >> main_config.txt
	cm="bash ${step}_bsub.sh"
	echo ${cm}
fi

## normalize unique reads
if [ "${step}" == "run_norm" ]
then
	seqDir=${outputDir_batchName}"run_uniq/"
	echo "seqDir=${seqDir}" >> main_config.txt
	outputPath=${outputDir_batchName}${step}"/"
	echo "outputPath=${outputPath}" >> main_config.txt
	mkdir -p ${outputPath}
	cm="bash ${step}_bsub.sh"
	echo ${cm}
fi

## detect CNV using normalized reads
if [ "${step}" == "run_detect" ]
then
	normDir=${outputDir_batchName}"run_norm/"
	step="run_detect"
	outputPath=${outputDir_batchName}${step}"/"
	mkdir -p ${outputPath}
	cm="bash ${step}.sh ${bamMapPath} ${segplPath} ${outputPath} ${fastaDir} ${mappabilityDir} ${normDir}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
	echo ${cm}
fi

## get unique reads
if [ "${step}" == "get_gene_level_cnv" ]
then
	detectDir=${outputDir_batchName}"run_detect/lambda3/"
	step="get_gene_level_cnv"
	outputPath=${outputDir_batchName}${step}"/"
	mkdir -p ${outputPath}
	cm="bash ${step}.sh ${detectDir} ${scriptDir} ${inputDir} ${outputPath} ${genelevelFile} ${version}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
	echo ${cm}
fi
