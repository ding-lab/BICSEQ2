#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Create normalization configuration file and run BICSeq normalization on all chromsomes
# Usage:
#   bash run_norm.sh [options] SAMPLE_NAME PROJECT_CONFIG 
#
# SAMPLE_NAME:  Unique name for this run
# PROJECT_CONFIG: Project configuration file
#
# Options:
#   -v: verbose
#   -d: dry run. Make normalization configuration file but do not execute BICSeq-norm script
#   -c CHRLIST: define chrom list, overriding value in PROJECT_CONFIG
#   -C norm_config: Use given normalization config file, rather than creating it
#   -w: issue warnings instead of fatal errors if files do not exist
#   -o OUTD_BASE: set output base root directory.  Defalt is /data1

# * Input
#   * Reads per-chrom reference, mapping, and seq files
#   * Iterates over CHRLIST
# * All output of this step written to $OUTD:
#   * normalization configuration file {SAMPLE_NAME}.norm-config.txt
#   * PDF written as {SAMPLE_NAME}.GC.pdf
#   * parameter estimate output (not used) in {SAMPLE_NAME}.out.txt
#   * Normalized data, per chrom, written to {SAMPLE_NAME}.{CHR}.norm.bin
#     * Note that this is written to config file used by NBICseq-norm.pl
#   * Tmp directory $OUTD/tmp created and passed as argument to NBICseq-norm.pl

SCRIPT=$(basename $0)

OUTD_BASE="/data1"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":vdc:C:wo:" opt; do
  case $opt in
    v)  
      VERBOSE=1
      ;;
    w)  
      WARN=1
      ;;
    d)  
      DRYRUN=1
      ;;
    c) # Define CHRLIST
      CHRLIST_ARG=$OPTARG
      ;;
    C) # define a normalization configuration file instead of writing it
      NORM_CONFIG=$OPTARG
      >&2 echo Norm config file passed: $NORM_CONFIG
      ;;
    o) 
      OUTD_BASE=$OPTARG
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR: Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR: Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


if [ "$#" -ne 2 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage:
    >&2 echo bash run_norm.sh \[options\] SAMPLE_NAME PROJECT_CONFIG 
    exit 1
fi

SAMPLE_NAME=$1
PROJECT_CONFIG=$2

if [ ! -e $PROJECT_CONFIG ]; then
    >&2 echo ERROR: Project configuration file $PROJECT_CONFIG not found
    exit 1
fi

# Note, OUTD_BASE must be defined prior to sourcing $PROJECT_CONFIG
>&2 echo Reading $PROJECT_CONFIG
source $PROJECT_CONFIG

if [ $CHRLIST_ARG ]; then
    CHRLIST=$CHRLIST_ARG
fi

if [ ! -e $CHRLIST ]; then
    >&2 echo ERROR: File $CHRLIST does not exist
    exit 1
fi

# Output, tmp, and log files go here
# Note that NORMD is set in project_config, but OUTD_BASE is set here.
OUTD=$NORMD

## create tmp directory
# TODO: be able to specify with -t
TMPD="$OUTD/tmp"
mkdir -p $TMPD

# Output:
# NORM_PDF - per sample
# OUTPARS - not generally used
# NORM_OUT - per chrom

OUTPARS=$OUTD/${SAMPLE_NAME}.out.txt

# Check to make sure file exists and its size is not zero
function confirm {
    FN=$1

    if [ ! -s $FN ]; then
        if [ $WARN ]; then
            >&2 echo Warning: $FN does not exist or is empty
        else
            >&2 echo ERROR: $FN does not exist or is empty
            exit 1
        fi
    fi
}

function write_norm_config {
    # Normalizaton configuration is distinct from project parameter configuration file
    NORM_CONFIG="$OUTD/${SAMPLE_NAME}.norm-config.txt"

    # Create configuration file by iterating over all chrom in CHRLIST
    ## Config file format defined here: http://compbio.med.harvard.edu/BIC-seq/
        # The first row of this file is assumed to be the header of the file and will be omitted by BICseq2-norm.
        # The 1st column (chromName) is the chromosome name
        # The 2nd column (faFile) is the reference sequence of this chromosome (human hg18 and hg19 are available for download)
        # The 3rd column (MapFile) is the mappability file of this chromosome (human hg18 (50bp) and hg19 (50bp and 75bp) are available for download)
        # The 4th column (readPosFile) is the file that stores all the mapping positions of all reads that uniquely mapped to this chromosome
        # The 5th column (binFile) is the file that stores the normalized data. The data will be binned with the bin size as specified by the option -b
    >&2 echo Writing normalization configuration $NORM_CONFIG
    printf "chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm\n" > $NORM_CONFIG
    while read CHR; do
        faFile=$(printf $FA_CHR $CHR)
        confirm $faFile   
        MapFile=$(printf $MAP_CHR $CHR)
        confirm $MapFile
        readPosFile=$(printf $SEQ_CHR $SAMPLE_NAME $CHR)
        confirm $readPosFile   
        binFile=$(printf $NORM_CHR $SAMPLE_NAME $CHR)
        printf "$CHR\t$faFile\t$MapFile\t$readPosFile\t$binFile\n" >> $NORM_CONFIG
    done<$CHRLIST
    >&2 echo Normalization configuration $NORM_CONFIG written successfully
}

# Skip writing configutation file if it has already been defined with -C
if [ ! $NORM_CONFIG ]; then
    write_norm_config
else
    confirm $NORM_CONFIG
fi

PDF=$(printf $NORM_PDF $SAMPLE_NAME)
CMD="perl $BICSEQ_NORM --tmp=$TMPD -l $READ_LENGTH -s $FRAG_SIZE -b $BIN_SIZE --fig $PDF $NORM_CONFIG $OUTPARS"
if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
fi

# Evaluate return value see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal ERROR $rc: $!.  Exiting.
    exit $rc;
fi

>&2 echo SUCCESS
