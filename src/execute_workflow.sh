#!/bin/bash
# Run BICSeq pipeline on tumor / normal pair to get somatic CNV calls.  Execuites in container
# Usage:
#   bash execute_pipeline [options] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM
#
# Mandatory arguments: 
#   PROJECT_CONFIG: project configuration file
#   CASE_NAME: name of run
#   SN_TUMOR, SN_NORMAL: sample names of tumor / normal
#   TUMOR_BAM, NORMAL_BAM: paths to tumor / normal sequence data

# Options:
# -d: dry run: print commands but do not run
#     This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
# -f: force overwrite of existing data, if it exists
# -j: number of parallel jobs for get_unique step [default 4]
# -s: step to run [ get_unique, normalization, segmentation, annotation, all ]
# -o OUTD_BASE: set output base root directory.  Defalt is /data1

# Details about BICSEQ2 pipeline: http://compbio.med.harvard.edu/BIC-seq/

function confirm {
    FN=$1
    if [ ! -e $FN ]; then
        >&2 echo ERROR: $FN does not exist
        exit 1
    fi
}

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

# Print timestamp and given string to stderr
function announce {
    TXT="$1"
    NOW=$(date)
    >&2 echo [ $NOW ] $0: $TXT
}

ARGS=""
GET_UNIQ_ARGS=""
STEP="all"	# this might be expanded to allow comma-separated steps
OUTD_BASE="/data1"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dfj:s:o:" opt; do
  case $opt in
    d)
      DRYRUN="d$DRYRUN" # -d is a stack of parameters, each script popping one off until get to -d
      ;;
    f)
      GET_UNIQ_ARGS="$GET_UNIQ_ARGS -f" 
      ;;
    j) 
      GET_UNIQ_ARGS="$GET_UNIQ_ARGS -j $OPTARG"
      ;;
    s) 
      STEP="$OPTARG"
      ;;
    o) 
      OUTD_BASE="$OPTARG"
      >&2 echo Output directory: $OUTD_BASE
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

if [ "$#" -ne 6 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage:
    >&2 echo bash execute_pipeline \[options\] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM
    exit 1
fi

CONFIG=$1
CASE_NAME=$2
SN_TUMOR=$3
TUMOR_BAM=$4
SN_NORMAL=$5
NORMAL_BAM=$6

confirm $CONFIG
confirm $TUMOR_BAM
confirm $NORMAL_BAM

# If DRYRUN is 'd' then we're in dry run mode (only print the called function),
# otherwise call the function as normal with one less -d argument than we got (passing DRYARG)
if [ -z $DRYRUN ]; then   # DRYRUN not set
    DRYARG=""
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    DRYARG=""
    >&2 echo Dry run in $0
else    # DRYRUN has multiple d's: pop one d off the argument and pass it to function
    DRYARG="-${DRYRUN%?}"
fi

ARGS="$ARGS $DRYARG "

# propagate output directory
ARGS="$ARGS -o $OUTD_BASE"

# -s: step to run [ get_unique, normalization, segmentation, annotation, all ]
if [ $STEP == "all" ]; then 
    RUN_UNIQUE=1
    RUN_NORM=1
    RUN_SEG=1
    RUN_ANN=1
elif [ $STEP == "get_unique" ]; then 
    RUN_UNIQUE=1
elif [ $STEP == "normalization" ]; then 
    RUN_NORM=1
elif [ $STEP == "segmentation" ]; then 
    RUN_SEG=1
elif [ $STEP == "annotation" ]; then
    RUN_ANN=1
else
    >&2 echo ERROR: Unknown step $STEP
    >&2 echo Valid values: get_unique, normalization, segmentation, annotation, all
    exit 1
fi
>&2 echo Running step $STEP

# Evaluate given command CMD either as dry run or for real
function run_cmd {
    CMD=$1

    if [ "$DRYRUN" == "d" ]; then
        >&2 echo Dryrun: $CMD
    else
        >&2 echo Running: $CMD
        eval $CMD
        test_exit_status
    fi
}

function process_sample {
# run get_unique and normalization steps on given sample
    SN=$1
    BAM=$2

    if [ $RUN_UNIQUE ]; then
        announce "$SN: Running get_unique step"
        CMD="bash /BICSEQ2/src/get_unique.sh $ARGS $GET_UNIQ_ARGS $SN $CONFIG $BAM"
        run_cmd "$CMD"
    fi

    if [ $RUN_NORM ]; then
        announce "$SN: Running normalization step"
        CMD="bash /BICSEQ2/src/run_norm.sh $ARGS $SN $CONFIG "
        run_cmd "$CMD"
    fi
}

process_sample $SN_TUMOR $TUMOR_BAM 
process_sample $SN_NORMAL $NORMAL_BAM 

if [ $RUN_SEG ]; then
    # Execute segmentation step using tumor/normal as case/control
    announce "Running segmentation step"
    CMD="bash /BICSEQ2/src/run_segmentation.sh $ARGS -s $CASE_NAME $SN_TUMOR $SN_NORMAL $CONFIG "
    run_cmd "$CMD"
fi

if [ $RUN_ANN ]; then
    announce "Running gene annotation step"
    CMD="bash /BICSEQ2/src/run_annotation.sh $ARGS $CASE_NAME $CONFIG"
    run_cmd "$CMD"
fi


