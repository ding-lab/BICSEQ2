#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Get the uniquely mapped reads from bam file, optionally in parallel runs
# Modeled after run_uniq.sh in v1
# Writes to directory $SEQD, filename is based SEQ_CHR when looping over CHRLIST, SEQ_OUT otherwise
# (By default $SAMPLE_NAME.CHR.seq and $SAMPLE_NAME.seq, resp)

# Usage: 
#   get_unique.sh [options] SAMPLE_NAME PROJECT_CONFIG BAM
#
# Options:
# -d : dry-run. Print commands but do not execute them
# -1 : stop after one.  If CHRLIST defined, launch only one job and proceed
# -c CHRLIST: Filename listing genomic reqions which will be processed in parallel.  Default is to process
#    all chromosomes at once.  This is similar to "chromosomes.txt" but lines will typically be "chr1", etc. 
#    This file is typically defined in PROJECT_CONFIG but may be overridden on command line.  "-c NONE" will
#    skip per-chrom processing
# -j JOBS: if parallel run, number of jobs to run at any one time (-j parameter to parallel).  Default: 4
# -f : Force overwrite if .seq files exist
# -o OUTD_BASE: set output root directory.  Defalt is /data1
#
# In parallel mode, will use [GNU parallel][1], but script will block until all jobs completed.
# Output logs written to $SAMPLE_NAME.$CHR.get_uniq.log
# Background on `parallel` and details about blocking / semaphores here:
#     O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#     ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)

# set defaults
PARALLEL_JOBS=4

OUTD_BASE="/data1"
# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dc:1fj:o:" opt; do
  case $opt in
    d)  # example of binary argument
      >&2 echo "Dry run" 
      DRYRUN=1
      ;;
    c) 
      CHRLIST_ARG=$OPTARG
      ;;
    1) 
      >&2 echo "Will stop after one element of CHRLIST" 
      JUSTONE=1
      ;;
    f) 
      FORCE_OVERWRITE=1
      ;;
    j) 
      PARALLEL_JOBS=$OPTARG  # not same as in execute_workflow.sh
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

if [ "$#" -ne 3 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage: get_unique.sh SAMPLE_NAME PROJECT_CONFIG BAM
    exit 1
fi

SAMPLE_NAME=$1
PROJECT_CONFIG=$2
BAM=$3

if [ ! -e $BAM ]; then
    >&2 echo ERROR: Bam file $BAM does not exist
    exit 1
fi

if [ ! -e $PROJECT_CONFIG ]; then
    >&2 echo ERROR: Project configuration file $PROJECT_CONFIG not found
    exit 1
fi

# Note, OUTD_BASE must be defined prior to sourcing $PROJECT_CONFIG
>&2 echo Reading $PROJECT_CONFIG
source $PROJECT_CONFIG

if [ $CHRLIST_ARG ]; then
    if [ $CHRLIST == "NONE" ]; then
        CHRLIST=""
    else
        CHRLIST=$CHRLIST_ARG
    fi
fi

# Output, tmp, and log files go here
# Note that SEQD is set in project_config, but OUTD_BASE is set here.
OUTD=$SEQD
mkdir -p $OUTD
TMPD="$OUTD/tmp"
mkdir -p $TMPD

## the path to the samtools getUnique helper script
SAMTOOLS_GU="/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"


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


# Simple direct processing of BAM
function process_BAM {
    BAM=$1

    NOW=$(date)
    # Output filename based on SEQ_OUT
    SEQ=$SEQ_OUT
    CMD="samtools view $BAM | perl $SAMTOOLS_GU unique - | cut -f 4 > $SEQ"
    if [ -e $SEQ ]; then
        if [ $FORCE_OVERWRITE ]; then
            >&2 echo NOTE: $SEQ exists.  Forcing overwrite \(-f\) of existing .seq data
        else
            >&2 echo ERROR: $SEQ exists.  Will not overwrite existing .seq data 
            exit 1
        fi
    fi
    >&2 echo [ $NOW ] Direct run of uniquely mapped reads.  Writing to $SEQD \; evaluating:
    if [ $DRYRUN ]; then
    >&2 echo Dryrun: $CMD
    else
        >&2 echo $CMD 
        eval $CMD
    fi
    test_exit_status
}

# Unlike original implementation which writes to commands.txt file, all jobs are run directly.
# Using semaphores to block as described here: https://www.usenix.org/system/files/login/articles/105438-Tange.pdf
# Skipping BAM header 
function process_BAM_parallel {
    BAM=$1
    CHRLIST=$2

    # CHRLIST newline-separated list of regions passed to samtools, e.g., 'chr1'
    #   Note that each line passed verbatim to `samtools view`

    # Processing chrom by chrom
    # background about parallel: https://www.usenix.org/system/files/login/articles/105438-Tange.pdf
    # Man page: https://www.gnu.org/software/parallel/man.html
    NOW=$(date)
    MYID=$(date +%Y%m%d%H%M%S)
    >&2 echo [ $NOW ]: Parallel run of uniquely mapped reads
    >&2 echo . 	  Looping over $CHRLIST
    >&2 echo . 	  Parallel jobs: $PARALLEL_JOBS
    while read CHR; do

        # Output filename based on SEQ_CHR
        SEQ=$(printf $SEQ_CHR $SAMPLE_NAME $CHR)
        if [ -e $SEQ ]; then
            if [ $FORCE_OVERWRITE ]; then
                >&2 echo NOTE: $SEQ exists.  Forcing overwrite \(-f\) of existing .seq data
            else
                >&2 echo ERROR: $SEQ exists.  Will not overwrite existing .seq data 
                exit 1
            fi
        fi

        JOBLOG="$LOGD/$SAMPLE_NAME.$CHR.get_uniq.log"
        CMD="samtools view $BAM $CHR | perl $SAMTOOLS_GU unique - | cut -f 4 > $SEQ"
        CMDP="parallel --semaphore -j$PARALLEL_JOBS --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
        >&2 echo Launching $CHR
        if [ $DRYRUN ]; then
            >&2 echo Dryrun: $CMDP
        else
            >&2 echo Running: $CMDP
            eval $CMDP
        fi
        test_exit_status

        if [ $JUSTONE ]; then
            break
        fi

    done<$CHRLIST

    NOW=$(date)
    >&2 echo [ $NOW ] All jobs launched.  Waiting for them to complete

    # this will wait until all jobs completed
    if [ ! $DRYRUN ]; then
        parallel --semaphore --wait --id $MYID
        test_exit_status
    fi

    NOW=$(date)
    >&2 echo [ $NOW ] All jobs have completed, written to $SEQD  
}

if [ ! $CHRLIST ]; then
# no chrom list
    >&2 echo Processing BAM singly
    process_BAM $BAM
else
    >&2 echo Processing BAM in parallel
    if [ ! -e $CHRLIST ]; then
        >&2 echo ERROR: File $CHRLIST does not exist
        exit 1
    fi
    process_BAM_parallel $BAM $CHRLIST
fi

>&2 echo SUCCESS
