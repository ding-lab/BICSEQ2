#!/bin/bash

# Get the uniquely mapped reads from bam file, optionally in parallel runs
# Modeled after run_uniq.sh

# Usage: 
#   get_unique.sh [options] BAM
#
# Options:
# -n SAMPLE_NAME: descriptive name of this sample or run. Default: Sample
# -d : dry-run. Print commands but do not execute them
# -o OUTD: directory where results and log files will be written, created if necessary.  Default: ./dat
# -c LIST: Filename listing genomic reqions which will be processed in parallel.  Default is to process
#    all chromosomes at once.  This is similar to "chromosomes.txt" but lines will typically be "chr1", etc. 
# -j JOBS: if parallel run, number of jobs to run at any one time (-j parameter to parallel).  Default: 4
#
# In parallel mode, will use [GNU parallel][1], but script will block until all jobs completed.
#     O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#     ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

# set detaults
SAMPLE_NAME="Sample"
OUTD="./dat"
PARALLEL_JOBS=4

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dn:o:j:c:" opt; do
  case $opt in
    d)  # example of binary argument
      >&2 echo "Dry run" 
      DRYRUN=1
      ;;
    n) 
      SAMPLE_NAME=$OPTARG
      >&2 echo "Sample name: $SAMPLE_NAME"
      ;;
    o) 
      OUTD=$OPTARG
      >&2 echo "Output directory: $OUTD"
      ;;
    j) 
      PARALLEL_JOBS=$OPTARG
      ;;
    c) 
      CHRLIST=$OPTARG
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

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage: get_unique.sh BAM
    exit 1
fi

BAM=$1

# Output and log files go here
mkdir -p $OUTD

## the path to the samtools getUnique helper script
samtoolsGU="/samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl"


function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}

# Unlike original implementation which writes to commands.txt file, all jobs are run directly.
# Using semaphores to block as described here: https://www.usenix.org/system/files/login/articles/105438-Tange.pdf
# Skipping BAM header 
function process_BAM {
    BAM=$1

    NOW=$(date)
    SEQ="$OUTD/${SAMPLE_NAME}.seq"
    CMD="samtools view $BAM | perl $samtoolsGU unique - | cut -f 4 > $SEQ"
    >&2 echo [ $NOW ] Direct run of uniquely mapped reads\; evaluating:
    if [ $DRYRUN ]; then
	>&2 echo Dryrun: $CMD
    else
        >&2 echo $CMD 
        eval $CMD
    fi
    test_exit_status
}

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
    >&2 echo [ $NOW ]: Parallel run of uniquely mapped reads\; looping over $CHRLIST
    while read CHR; do
        SEQ="$OUTD/${SAMPLE_NAME}_${CHR}.seq"
        CMD="samtools view $BAM $CHR | perl $samtoolsGU unique - | cut -f 4 > $SEQ"
        CMDP="parallel --semaphore -j $PARALLEL_JOBS --id $MYID --joblog $OUTD/$SAMPLE_NAME.get_uniq.log $CMD"
        >&2 echo Launching $CHR
        if [ $DRYRUN ]; then
            >&2 echo Dryrun: $CMDP
        else
            >&2 echo $CMDP
            eval $CMDP
        fi
        test_exit_status

    done<$CHRLIST

    NOW=$(date)
    >&2 echo [ $NOW ] All jobs launched.  Waiting for them to complete

    # this will wait until all jobs completed
    if [ ! $DRYRUN ]; then
        parallel --semaphore --wait --id $MYID
    fi

    NOW=$(date)
    >&2 echo [ $NOW ] All jobs have completed.  get_unique.sh finished
}

if [ -z $CHRLIST ]; then
# no chrom list
    process_BAM $BAM
else
	if [ ! -e $CHRLIST ]; then
		>&2 echo Error: File $CHRLIST does not exist
		exit 1
	fi
    process_BAM_parallel $BAM $CHRLIST
fi

