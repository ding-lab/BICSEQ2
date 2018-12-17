#!/bin/bash

## the path to the WGS BAM map
bamMapPath=$1
## the path to the samtools helper script
segplPath=$2
## the path to the output directory for this batch
outputPath=$3
## the path to the by chromosome fasta file
fastaDir=$4
## the path to the mappability file
mappabilityDir=$5
## the path to the .seq file
normDir=$6

## create tmp directory
tmpDir=${outputPath}"TMP/"
mkdir -p ${tmpDir}

## create log directory
logDir=${outputPath}"logs/"
mkdir -p ${logDir}

## generate commands
touch ${outputPath}"commands.txt" > ${outputPath}"commands.txt"

cat sample.txt | while read Case tumor normal
do
        ## create config file
	echo -e 'chromName\tbinFileNorm.Case\tbinFileNorm.Control' > ${outputPath}${Case}"_seg_config.txt"
	while read chr; do
		echo -e 'chr'${chr}'\t'${normDir}${Case}"_tumor_chr"${chr}"_norm.bin\t"${normDir}${Case}"_blood_normal_chr"${chr}"_norm.bin" >> ${outputPath}${Case}"_seg_config.txt"
	done<chromosomes.txt
	## genrate commands for parallel
	for lambda in 3; do
		outputPath_tmp=${outputPath}"lambda"${lambda}"/"
		mkdir -p ${outputPath_tmp}
		if [ -s ${outputPath_tmp}${Case}".CNV" ]
		then
			echo "" >> ${outputPath_tmp}commands.txt
		else
			echo "perl "${segplPath}" --detail --control --lambda="${lambda}" --noscale --tmp="${tmpDir}" --fig "${outputPath_tmp}${Case}"_seg.pdf "${outputPath}${Case}"_seg_config.txt "${outputPath_tmp}${Case}".CNV" >> ${outputPath}"commands.txt"
		fi
	done
done
cat ${outputPath}"commands.txt" | uniq | parallel  --resume-failed --joblog ${logDir}$(date +%Y%m%d%H%M%S).log -j 25 {} &
