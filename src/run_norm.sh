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

# set defaults
PARALLEL_JOBS=4
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
mkdir -p $OUTD
## create tmp directory
# TODO: be able to specify with -t
TMPD="$OUTD/tmp"
mkdir -p $TMPD
LOGD="$OUTD/log"
mkdir -p ${LOGD}

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

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo $SCRIPT Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}


# Skip writing configutation file if it has already been defined with -C
if [ ! $NORM_CONFIG ]; then
    write_norm_config
else
    confirm $NORM_CONFIG
fi

PDF=$(printf $NORM_PDF $SAMPLE_NAME)
CMD="perl $BICSEQ_NORM --tmp=$TMPD -l $READ_LENGTH -s $FRAG_SIZE -b $BIN_SIZE --fig $PDF $NORM_CONFIG $OUTPARS"
JOBLOG="${LOGD}/${SAMPLE_NAME}.norm.log"
MYID=$(date +%Y%m%d%H%M%S)
CMDP="parallel -j$PARALLEL_JOBS --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
if [ $DRYRUN ]; then
    >&2 echo Dry run: $CMDP
else
    >&2 echo Running: $CMDP
    eval ${CMDP}
    >&2 echo Finished eval
    test_exit_status

    NOW=$(date)
    >&2 echo [ $NOW ] ${SAMPLE_NAME} job launched.  Waiting for them to complete

    # this will wait until all jobs completed
    if [ ! $DRYRUN ]; then
        parallel --semaphore --wait --id $MYID
        test_exit_status
    fi

    NOW=$(date)
    >&2 echo [ $NOW ] ${SAMPLE_NAME} job has completed
fi

# Evaluate return value see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal ERROR $rc: $!.  Exiting.
    exit $rc;
fi

## Evaluate whether there is an excess of 0s in the norm.bin files
### create a directory for files for inspection
mkdir -p $INSPD
INSP_NORMD=$INSPD"/norm/"
mkdir -p $INSP_NORMD
while read CHR; do
    binFile=$(printf $NORM_CHR $SAMPLE_NAME $CHR)
    distrFile=${INSP_NORMD}${SAMPLE_NAME}"."${CHR}".column3.distr.txt"
    cat $binFile | cut -f 3| sort | uniq -c | sort -nr > ${distrFile} 
    if [ "$CHR" != "chrX" ] && [ "$CHR" != "chrY" ]; then
        number_top=$(head -1 ${distrFile} | awk -F ' ' '{print $2}') 
        if [[ $number_top = 0 ]]; then
            >&2 echo ERROR: Excess 0s in $binFile. Exiting.
            exit 1
        fi
    fi
done<$CHRLIST
>&2 echo SUCCESS
