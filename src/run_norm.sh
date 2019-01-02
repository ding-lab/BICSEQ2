#!/bin/bash

# Run BICSeq normalization on all chromsomes
# Usage:
#   bash run_norm.sh [options] SAMPLE_NAME PROJECT_CONFIG 
#
# SAMPLE_NAME:  Unique name for this run
# PROJECT_CONFIG: Project configuration file
#
# Options:
#   -v: verbose
#   -d: dry run. Make configuration file but do not execute BICSeq-norm script
#   -c CHRLIST: define chrom list, overriding value in PROJECT_CONFIG

# * Input
#   * Reads per-chrom reference, mapping, and seq files
#   * Iterates over CHRLIST
# * All output of this step written to $OUTD:
#   * normalization configuration file {SAMPLE_NAME}.config.txt
#   * PDF written as {SAMPLE_NAME}.GC.pdf
#   * parameter estimate output (not used) in {SAMPLE_NAME}.out.txt
#   * Normalized data, per chrom, written to {SAMPLE_NAME}.{CHR}.norm.bin
#     * Note that this is written to config file used by NBICseq-norm.pl
#   * Tmp directory $OUTD/tmp created and passed as argument to NBICseq-norm.pl

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":vdc:" opt; do
  case $opt in
    v)  # example of binary argument
      VERBOSE=1
      ;;
    d)  # example of binary argument
      DRYRUN=1
      ;;
    c) # example of value argument
      CHRLIST_ARG=$OPTARG
      ;;
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
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage:
    >&2 echo bash run_norm.sh \[options\] SAMPLE_NAME PROJECT_CONFIG 
    exit 1
fi

SAMPLE_NAME=$1
PROJECT_CONFIG=$2

if [ ! -e $PROJECT_CONFIG ]; then
    >&2 echo Error: Project configuration file $PROJECT_CONFIG not found
    exit 1
fi

>&2 echo Reading $PROJECT_CONFIG
source $PROJECT_CONFIG

if [ $CHRLIST_ARG ]; then
    CHRLIST=$CHRLIST_ARG
fi

if [ ! -e $CHRLIST ]; then
    >&2 echo Error: File $CHRLIST does not exist
    exit 1
fi

OUTD=$NORMD

# Normalizaton configuration is distinct from project parameter configuration file
NORM_CONFIG="$OUTD/${SAMPLE_NAME}.config.txt"

## create tmp directory
# be able to specify with -t
TMPD="$OUTD/tmp"
mkdir -p $TMPD

# V1 names
#chromName="chr${chr}"
#faFile="${REF}chr${chr}.fa"
#MapFile="${MAPD}${MER}.chr${chr}.txt"
#readPosFile="${SEQD}${Case}_${SampType}_chr${chr}.seq"
#binFileNorm="${OUTD}${Case}_${SampType}_chr${chr}_norm.bin" 

# Output:
# NORM_PDF - per sample
# OUTPARS - not generally used
# NORM_OUT - per chrom

OUTPARS=${SAMPLE_NAME}.out.txt

# Create configuration file by iterating over all chrom in CHRLIST
## Config file format defined here: http://compbio.med.harvard.edu/BIC-seq/
    # The first row of this file is assumed to be the header of the file and will be omitted by BICseq2-norm.
    # The 1st column (chromName) is the chromosome name
    # The 2nd column (faFile) is the reference sequence of this chromosome (human hg18 and hg19 are available for download)
    # The 3rd column (MapFile) is the mappability file of this chromosome (human hg18 (50bp) and hg19 (50bp and 75bp) are available for download)
    # The 4th column (readPosFile) is the file that stores all the mapping positions of all reads that uniquely mapped to this chromosome
    # The 5th column (binFile) is the file that stores the normalized data. The data will be binned with the bin size as specified by the option -b
>&2 echo Writing normalization configuration $NORM_CONFIG
printf "chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm" > $NORM_CONFIG
while read CHR; do
    faFile=$(printf $FA_CHR $CHR)
    MapFile=$(printf $MAP_CHR $CHR)
    readPosFile=$(printf $SEQ_CHR $CHR)
    binFile=$(printf $NORM_CHR $CHR)
    printf "$CHR\t$faFile\t$MapFile\t$readPosFile\t$binFile" >> $NORM_CONFIG
done<$CHRLIST

CMD="perl $BICSEQ_NORM --tmp=$TMPD -l $READ_LENGTH -s $FRAG_SIZE -b $BIN_SIZE --fig $PDF $NORM_CONFIG $OUTPARS"
if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    eval $CMD
fi


# Evaluate return value see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi

