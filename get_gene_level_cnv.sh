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

## the below code does the following steps:
### sed '1d' $file: take in .CNV file and take out the first row
### cut -f1,2,3,9: keep columns representing chromosome, CNV start, CNV end and log2(copy ratio)
### bedtools intersect -loj -a ${geneBedFile} -b -: intersect with gene annotation file, whose outputs have columns representing (1) chromosome, (2) gene start, (3) gene end, (4) gene symbol, (5) chromosome, (6) CNV start, (7) CNV end, (8) CNV log2(copy ratio).
###  
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
