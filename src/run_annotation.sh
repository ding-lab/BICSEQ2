#!/bin/bash
## get gene-level copy number values for given case
#
# Usage:
#   bash run_annotation.sh [options] CASE_NAME PROJECT_CONFIG
#
# CASE_NAME is as used for run_segmenation step; refers to common origin of tumor/normal samples
#
# Options:
# -d: dry run: print command but do not execute
#
# Input:
#  * .cnv file output by run_segmentation step
#  * gene annotation bed file, created by prep_gene_annotation step (specific to ensembl build)
# 
# Output:
#  * Gene level CNV file like CASE.gene_level.log2.seg, written to annotation directory

# Previous data on Katmai
# detectDir: /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/BICSEQ2.UCEC.hg38.121/run_detect/lambda3
# outputPath: /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/BICSEQ2.UCEC.hg38.121/get_gene_level_cnv

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}


# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":d" opt; do
  case $opt in
    d)  
      DRYRUN=1
      ;;
#    s) # example
#      CASE_NAME_ARG=$OPTARG
#      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage:
    >&2 echo bash run_annotation.sh \[options\] CASE_NAME PROJECT_CONFIG
    exit 1
fi

CASE_NAME=$1
PROJECT_CONFIG=$2

if [ ! -e $PROJECT_CONFIG ]; then
    >&2 echo ERROR: Project configuration file $PROJECT_CONFIG not found
    exit 1
fi

>&2 echo Reading $PROJECT_CONFIG
source $PROJECT_CONFIG

if [ ! -e $GENE_BED ]; then
    >&2 echo ERROR: Gene annotation file $GENE_BED not found
    exit 1
fi

OUTD=$ANND
mkdir -p $OUTD

CNV=$(printf $SEG_CNV $CASE_NAME)
GL_OUT=$(printf $GL_CASE $CASE_NAME)

if [ ! -e $CNV ]; then
    >&2 echo ERROR: CNV input file $CNV not found
    exit 1
fi

# Note, one CNV per sample.  
CMD="sed '1d' $CNV | cut -f1,2,3,9 | /usr/bin/bedtools intersect -loj -a $GENE_BED -b - | /usr/bin/python $SRCD/gene_segment_overlap.py > $GL_OUT"

if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    >&2 echo Written to $GL_OUT
fi

>&2 echo SUCCESS

# Note, not merging across all samples into final result named e.g. gene_level_CNV.BICSEQ2.UCEC.hg38.121.v1.2.tsv
# Code below from https://github.com/ding-lab/BICSEQ2/blob/master/get_gene_level_cnv.sh

# ls *.CNV | cut -f1 -d'.' > ${outputPath}samples.txt
# genelevelFile="gene_level_CNV"
# version=1.2
# batchName="BICSEQ2.UCEC.hg38.121"
# genelevelOut=${genelevelFile}"."${batchName}".v"${version}".tsv"
# echo gene > ${genelevelOut}
# cut -f1 $(head -1 samples.txt).gene_level.log2.seg >> ${genelevelOut}
# cat samples.txt | while read sample; do
# 	echo ${sample}
# 	echo $sample > smp
# 	cut -f5 $sample.gene_level.log2.seg >> smp
# 	paste ${genelevelOut} smp > tmp2
# 	mv -f tmp2 ${genelevelOut}
# 	rm -f smp
# done
