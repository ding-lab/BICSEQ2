#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

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
# -s: step to run [ get_unique, normalization, segmentation, annotation, clean, reset, all ]
# -o OUTD_BASE: set output base root directory.  Defalt is /data1
# -C CLEAN_OPT: options for `clean` step.  CLEAN_OPT may be one of:
#   * none: do nothing
#   * compress: Create .tar.gz for unique_reads and norm directories, then delete directories.  This is the default
#   * delete: delete unique_reads and norm directories (and their corresponding .tar.gz if they exist)

# The reset step is a special step which deletes all log and result data.  It is dangerous because data loss will occur, 
# but useful way to reset output directory to state where another run can cleanly take place.  

# Details about BICSEQ2 pipeline: http://compbio.med.harvard.edu/BIC-seq/

SCRIPT=$(basename $0)

# Usage
# write_log STATUS "message"
# where STATUS should be START, SUCCESS, ERROR
# prints standardized format log string to stderr
function write_log {
    printf "BS2:%s\t%s\t[ %s ]\t%s\n" "$1" "$SCRIPT" "$(date)" "$2" 1>&2
}

# Usage:   write_START "message"
function write_START {
    write_log "START" "$1"
}

# Usage:   write_SUCCESS "message"
function write_SUCCESS {
    write_log "SUCCESS" "$1"
}

# Usage:   write_ERROR "message"
function write_ERROR {
    write_log "ERROR" "$1"
}

function confirm {
    FN=$1
    if [ ! -e $FN ]; then
        #>&2 echo ERROR: $FN does not exist
        write_ERROR "$FN does not exist"
        exit 1
    fi
}

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            #>&2 echo $SCRIPT: Fatal ERROR.  Exiting.
            write_ERROR "Fatal ERROR.  Exiting."
            exit $rc;
        fi;
    done
}

write_START

ARGS=""
GET_UNIQ_ARGS=""
STEP="all"	# this might be expanded to allow comma-separated steps
OUTD_BASE="/data1"
CLEAN_OPT="compress"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dfj:s:o:C:" opt; do
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
    C) 
      CLEAN_OPT="$OPTARG"
      ;;
    \?)
      #>&2 echo "$SCRIPT: ERROR: Invalid option: -$OPTARG"
      write_ERROR "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      #>&2 echo "$SCRIPT: ERROR: Option -$OPTARG requires an argument."
      write_ERROR "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 6 ]; then
#    >&2 echo ERROR: Wrong number of arguments
#    >&2 echo Usage:
#    >&2 echo bash execute_pipeline \[options\] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM

# https://stackoverflow.com/questions/1167746/how-to-assign-a-heredoc-value-to-a-variable-in-bash
read -r -d '' MSG<<'EOF'
Wrong number of arguments 
Usage: 
bash execute_pipeline \[options\] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM
EOF
    write_ERROR "$MSG"
    exit 1
fi

if [ $CLEAN_OPT != "none" ] && [ $CLEAN_OPT != "compress" ] && [ $CLEAN_OPT != "delete" ]; then
    write_ERROR "Unknown CLEAN_OPT = $CLEAN_OPT"
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

# -s: step to run [ get_unique, normalization, segmentation, annotation, clean, reset, all ]
if [ $STEP == "all" ]; then 
    RUN_UNIQUE=1
    RUN_NORM=1
    RUN_SEG=1
    RUN_ANN=1
    RUN_CLEAN=1
elif [ $STEP == "get_unique" ]; then 
    RUN_UNIQUE=1
elif [ $STEP == "normalization" ]; then 
    RUN_NORM=1
elif [ $STEP == "segmentation" ]; then 
    RUN_SEG=1
elif [ $STEP == "annotation" ]; then
    RUN_ANN=1
elif [ $STEP == "clean" ]; then
    RUN_CLEAN=1
elif [ $STEP == "reset" ]; then
    RUN_RESET=1
else
    >&2 echo ERROR: Unknown step $STEP
    >&2 echo Valid values: get_unique, normalization, segmentation, annotation, clean, all
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
        write_START "$SN: Running get_unique step"
        CMD="bash /BICSEQ2/src/get_unique.sh $ARGS $GET_UNIQ_ARGS $SN $CONFIG $BAM"
        run_cmd "$CMD"
    fi

    if [ $RUN_NORM ]; then
        write_START "$SN: Running normalization step"
        CMD="bash /BICSEQ2/src/run_norm.sh $ARGS $SN $CONFIG "
        run_cmd "$CMD"
    fi
}

mkdir -p $OUTD_BASE
test_exit_status

if [ $RUN_RESET ]; then
    write_START "Running reset step"
    run_cmd "rm -rf $OUTD_BASE/* "
    exit 0  # successful completion
fi

if [ $RUN_UNIQUE ] || [ $RUN_NORM ]; then
    write_START "$CASE Tumor"
    process_sample $SN_TUMOR $TUMOR_BAM 

    write_START "$CASE Normal"
    process_sample $SN_NORMAL $NORMAL_BAM 
fi

if [ $RUN_SEG ]; then
    # Execute segmentation step using tumor/normal as case/control
    write_START "Running segmentation step"
    CMD="bash /BICSEQ2/src/run_segmentation.sh $ARGS -s $CASE_NAME $SN_TUMOR $SN_NORMAL $CONFIG "
    run_cmd "$CMD"
fi

if [ $RUN_ANN ]; then
    write_START "Running gene annotation step"
    CMD="bash /BICSEQ2/src/run_annotation.sh $ARGS $CASE_NAME $CONFIG"
    run_cmd "$CMD"
fi

# Typical output size:
# 1.0M    annotation
# 256K    bsub
# 1.9G    norm
# 320K    segmentation
# 0   tmp
# 8.2G    unique_reads

# Cleanup step aims to reduce disk usage by either compressing or deleting the unique_reads and norm directories
if [ $RUN_CLEAN ]; then
    write_START "Running cleanup step"
    
    if [ $CLEAN_OPT == "compress" ]; then
        # if the .tar.gz already exists, skip compression, so that running this twice does not give an error
        if [ -d $OUTD_BASE/unique_reads ] && [ ! -e $OUTD_BASE/unique_reads.tar.gz ]; then
            run_cmd "tar -P -zcf $OUTD_BASE/unique_reads.tar.gz $OUTD_BASE/unique_reads"
            run_cmd "rm -rf $OUTD_BASE/unique_reads "
        fi
        if [ -d $OUTD_BASE/norm ] && [ ! -e $OUTD_BASE/norm.tar.gz ]; then
            run_cmd "tar -P -zcf $OUTD_BASE/norm.tar.gz $OUTD_BASE/norm"
            run_cmd "rm -rf $OUTD_BASE/norm"
        fi
    elif [ $CLEAN_OPT == "delete" ]; then
        run_cmd "rm -rf $OUTD_BASE/unique_reads $OUTD_BASE/unique_reads.tar.gz $OUTD_BASE/norm $OUTD_BASE/norm.tar.gz"
    else
        >&2 echo "No cleanup"
    fi
fi

write_SUCCESS
