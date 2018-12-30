#!/bin/bash

normplPath="/diskmnt/Projects/Users/qgao/Tools/BICSeq2/NBICseq-norm_v0.2.4/NBICseq-norm.pl"


## the path to the output directory for this batch
OUTD=$3
## the path to the by chromosome fasta file
REF=$4
## the path to the mappability file
mappabilityDir=$5
## the path to the .seq file
seqDir=${outputPath}
## the prefix of the mappability file
mappabilityPrefix=$7

## create log directory
logDir=${OUTD}"logs/"
mkdir -p ${logDir}

## create tmp directory
# be able to specify with -t
tmpDir=${OUTD}"TMP/"
mkdir -p ${tmpDir}


SAMPLE_NAME="Sample"

CONFIG="$OUTD/${SAMPLE_NAME}_config.txt"

## create config file, defined here: http://compbio.med.harvard.edu/BIC-seq/
# The first row of this file is assumed to be the header of the file and will be omitted by BICseq2-norm.
# The 1st column (chromName) is the chromosome name
# The 2nd column (faFile) is the reference sequence of this chromosome (human hg18 and hg19 are available for download)
# The 3rd column (MapFile) is the mappability file of this chromosome (human hg18 (50bp) and hg19 (50bp and 75bp) are available for download)
# The 4th column (readPosFile) is the file that stores all the mapping positions of all reads that uniquely mapped to this chromosome
# The 5th column (binFile) is the file that stores the normalized data. The data will be binned with the bin size as specified by the option -b

printf "chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm" > $CONFIG
chromName="chr${chr}"
faFile="${REF}chr${chr}.fa"
MapFile="${mappabilityDir}${mappabilityPrefix}.chr${chr}.txt"
readPosFile="${seqDir}${Case}_${SampType}_chr${chr}.seq"
binFileNorm="${OUTD}${Case}_${SampType}_chr${chr}_norm.bin" 

PDF="${OUTD}${Case}_${SampType}_GC.pdf"

while read chr; do
    printf "$chromName\t$faFile\t$MapFile\t$readPosFile\t$binFileNorm" >> $CONFIG
done<chromosomes.txt

## genrate commands for parallel
nohup perl ${normplPath} --tmp=${tmpDir} -l 150 -s 350 -b 100 --fig "${OUTD}${Case}"_"${SampType}"_GC.pdf "${OUTD}${Case}"_"${SampType}"_config.txt "${OUTD}${Case}"_"${SampType}"_out.txt" 
fi


#cat ${OUTD}"commands.txt" | uniq | parallel --resume-failed --joblog ${logDir}$(date +%Y%m%d%H%M%S).log -j 24 {} &
