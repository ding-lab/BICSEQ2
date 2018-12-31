#!/bin/bash

source /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/BICSEQ2.LUAD.b5_6/main_config.txt
## the directory to the log files
#logDir=${outputPath}"logs/"
#mkdir -p ${logDir}
step="run_uniq"

touch ${outputPath}"commands.txt" > ${outputPath}"commands.txt"

cat sample.txt | while read Case
do
        for SampType in tumor blood_normal; do
		## get the BAM file
		bamPath=$(cat ${bamMapPath} | grep ${bamType} | grep ${genomeBuild} | grep ${Case} | grep ${SampType} | awk '{print $6}')
                while read chr; do
			if [ -s ${outputPath}${Case}_${SampType}_chr${chr}.seq ]
			then
				echo ""  >> ${outputPath}commands.txt
			else
				touch ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh" > ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh"
				echo "#!/bin/bash" >> ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh"
				cm="samtools view -h ${bamPath} chr${chr} | perl ${samtoolsPath} unique - | cut -f 4 > ${outputPath}${Case}_${SampType}_chr${chr}.seq"
				echo ${cm} >> ${outputPath}"${Case}_${SampType}_chr${chr}_commands.sh"
				bsub -o /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/logs/${step}_${Case}_${SampType}_chr${chr}_$(date +%Y%m%d%H%M%S).log -q research-hpc -M 4000000 -R 'select[mem>40] span[hosts=1] rusage[mem=40]' -n 1 -a 'docker(yigewu/bicseq2:v2)' bash ${outputPath}${Case}"_"${SampType}"_chr"${chr}"_commands.sh"
			fi
                done<chromosomes.txt
        done
done
