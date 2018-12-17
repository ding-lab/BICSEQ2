#!/bin/bash

## the path to the WGS BAM map
bamMapPath=$1
## the path to the samtools helper script
samtoolsPath=$2
## the path to the output directory for this batch
outputPath=$3
## the bam type
bamType=$4
## the genome Build
genomeBuild=$5
## the directory to the log files
logDir=${outputPath}"logs/"
mkdir -p ${logDir}

cat ${outputPath}"commands.txt" | uniq | parallel --resume-failed --joblog ${logDir}$(date +%Y%m%d%H%M%S).log  -j 24 {} &

exit 1

touch ${outputPath}"commands.txt" > ${outputPath}"commands.txt"

cat sample.txt | while read Case
do
        for SampType in tumor blood_normal; do
		## get the BAM file
		bamPath=$(cat ${bamMapPath} | grep ${bamType} | grep ${genomeBuild} | grep ${Case} | grep ${SampType} | awk '{print $6}')
                while read chr; do
			if [ -s ${outputPath}${Case}_${SampType}_chr${chr}.seq ]
			then
				ls -r ${logDir} | while read logFile; do
					exitVal=$(grep ${Case}_${SampType}_chr${chr}.seq ${logDir}${logFile} | awk -F '\t' '{print $7}')
					signal=$(grep ${Case}_${SampType}_chr${chr}.seq ${logDir}${logFile} | awk -F '\t' '{print $8}')
					if [ "${exitVal}" == "0" ] & [ "${signal}" == "0" ]
					then
						break
					else
						if grep -Fq ${Case}_${SampType}_chr${chr}.seq $(cat ${logDir}${logFile})
						then
							cm="samtools view -h ${bamPath} chr${chr} | perl ${samtoolsPath} unique - | cut -f 4 > ${outputPath}${Case}_${SampType}_chr${chr}.seq"
							echo ${cm} >> ${outputPath}commands.txt
						fi
					fi
				done
			else
				cm="samtools view -h ${bamPath} chr${chr} | perl ${samtoolsPath} unique - | cut -f 4 > ${outputPath}${Case}_${SampType}_chr${chr}.seq"
				echo ${cm} >> ${outputPath}commands.txt
			fi
                done<chromosomes.txt
        done
done

#cat ${outputPath}"commands.txt" | uniq | parallel --resume-failed --joblog ${logDir}$(date +%Y%m%d%H%M%S).log  -j 12 {} &
