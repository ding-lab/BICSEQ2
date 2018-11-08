#!/bin/bash

## the path to the WGS BAM map
bamMapPath=$1
## the path to the samtools helper script
normplPath=$2
## the path to the output directory for this batch
outputPath=$3
## the path to the by chromosome fasta file
fastaDir=$4
## the path to the mappability file
mappabilityDir=$5
## the path to the .seq file
seqDir=$6
## the prefix of the mappability file
mappabilityPrefix=$7

## create log directory
logDir=${outputPath}"logs/"
mkdir -p ${logDir}

## create tmp directory
tmpDir=${outputPath}"TMP/"
mkdir -p ${tmpDir}

touch ${outputPath}"commands.txt" > ${outputPath}"commands.txt"

cat sample.txt | while read Case tumor normal
do
	for SampType in tumor blood_normal; do
	## create config file
		echo -e 'chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm' > ${outputPath}${Case}"_"${SampType}"_config.txt"
		while read chr; do
			echo -e 'chr'${chr}'\t'${fastaDir}'chr'${chr}'.fa\t'${mappabilityDir}${mappabilityPrefix}".chr"${chr}".txt\t"${seqDir}${Case}"_"${SampType}"_chr"${chr}".seq\t"${outputPath}${Case}"_"${SampType}"_chr"${chr}"_norm.bin" >> ${outputPath}${Case}"_"${SampType}"_config.txt"
		done<chromosomes.txt
	## genrate commands for parallel
		if [ -s ${outputPath}${Case}"_"${SampType}"_out.txt" ]
		then
			echo "" >> ${outputPath}"commands.txt"
		else
			echo "nohup perl "${normplPath}" --tmp="${tmpDir}" -l 150 -s 350 -b 100 --fig "${outputPath}${Case}"_"${SampType}"_GC.pdf "${outputPath}${Case}"_"${SampType}"_config.txt "${outputPath}${Case}"_"${SampType}"_out.txt" >> ${outputPath}"commands.txt"
		fi
	done
done

cat ${outputPath}"commands.txt" | uniq | parallel --resume-failed --joblog ${logDir}$(date +%Y%m%d%H%M%S).log -j 10 {} &
