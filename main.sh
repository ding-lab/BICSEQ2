#!/bin/bash

## the name of the master directory holding inputs, outputs and processing codes
toolName="BICSEQ2"
## the name of the batch
batchName="UCEC.b4"
## the name the directory holding the processing code
toolDirName=${toolName}"."${batchName}
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
## the link to the mappability files
mappabilityLink="http://compbio.med.harvard.edu/BIC-seq/Mappability/hg19.CRG.100bp.tar.gz"
## the path to the directory holding the manifest for BAM files
bamMapPath="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/CPTAC3.catalog/katmai.BamMap.dat"
## the path to the samtools helper script
samtoolsPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"
## the path to the BICseq2-norm perl script
normplPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/NBICseq-norm_v0.2.4/NBICseq-norm.pl"
## the path to the BICseq2-seg perl script
segplPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/NBICseq-seg_v0.7.2/NBICseq-seg.pl"
## the path to the by chromosome fasta file
fastaDir="/diskmnt/Datasets/Reference/GenomeSTRiP/Homo_sapiens_assembly19/chromosome/"
## the path to the mappability file
mappabilityDir="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/hg19CRG.100bp/"
## the file prefix for the gene-level CNV report
genelevelFile="gene_level_CNV"
## the name of the processing version
version=1.1

#bash -c 'source activate bicseq2'

## get dependencies
step="get_dependencies"
cm="bash ${step}.sh ${inputDir} ${bamMapGit} ${mappabilityLink} ${bicseq2normLink} ${bicseq2segLink}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}

## get unique reads
step="run_uniq"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${bamMapPath} ${samtoolsPath} ${outputPath} &"
echo ${cm}

## get unique reads
seqDir=${outputPath}
step="run_norm"
outputPath=${outputDir_batchName}${step}"/"
mkdir -p ${outputPath}
cm="bash ${step}.sh ${bamMapPath} ${normplPath} ${outputPath} ${fastaDir} ${mappabilityDir} ${seqDir}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
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
cm="bash ${step}.sh ${detectDir} ${scriptDir} ${inputDir} ${outputPath} ${genelevelFile} ${version}>&${logDir}${toolDirName}_${step}_$(date +%Y%m%d%H%M%S).log &"
echo ${cm}
