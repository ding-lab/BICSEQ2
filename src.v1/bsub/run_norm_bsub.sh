#!/bin/bash

#source /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/BICSEQ2.LUAD.b5_6/main_config.txt
source ./main_config.txt
## create tmp directory
tmpDir=${outputPath}"TMP/"
mkdir -p ${tmpDir}

step="run_norm"
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
			echo ${outputPath}${Case}"_"${SampType}"_out.txt done!"
		else
                      	touch ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh" > ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh"
                        echo "#!/bin/bash" >> ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh"
			cm="perl "${normplPath}" --tmp="${tmpDir}" -l ${readLength} -s 350 -b 100 --fig "${outputPath}${Case}"_"${SampType}"_GC.pdf "${outputPath}${Case}"_"${SampType}"_config.txt "${outputPath}${Case}"_"${SampType}"_out.txt"
			echo ${cm} >> ${outputPath}"${Case}_${SampType}_commands.sh"
			bsub -o ${logDir}${step}_${Case}_${SampType}_$(date +%Y%m%d%H%M%S).log -q research-hpc -M 4000000 -R 'select[mem>40] span[hosts=1] rusage[mem=40]' -n 1 -a 'docker(yigewu/bicseq2:v2)' bash ${outputPath}${Case}"_"${SampType}"_commands.sh"
			exit
		fi
	done
done

