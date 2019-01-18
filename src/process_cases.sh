#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# launch BICSEQ2 workflow for multiple cases.  Run from host

# takes list of case names and starts processing on each, calling `execute_workflow CASE`
# Reads CaseList to get details (BAM, etc.) for each case.  Runs on host computer
# Based on https://github.com/ding-lab/importGDC/blob/master/start_step.sh

# Usage:
#   bash process_cases.sh -S CASE_LIST -p PROJECT_CONFIG [options] CASE [CASE2 ...]
# 
# One or more CASEs required.  If CASE is - then read CASE from STDIN
#
# Required options:
# -S CASE_LIST: path to CASE LIST data file
# -p PROJECT_CONFIG: project configuration file.  Will be mapped to /project_config.sh in container
# -L LOGD_BASE_PROJECT: Log base dir relative to host.  Logs of parallel / bsub will be LOGD_PROJECT_BASE/CASE
#
# Optional options
# -d: dry run: print commands but do not run
#     This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
# -1 : stop after one case processed.
# -f: force overwrite of existing data, if it exists
# -g LSF_GROUP: LSF group to use starting job (MGI specific)
#       details: https://confluence.ris.wustl.edu/pages/viewpage.action?pageId=27592450
#       See also https://github.com/ding-lab/importGDC.CPTAC3
# -s: step to run [ get_unique, normalization, segmentation, annotation, clean, reset, all ].  Default is all
# -m DOCKERMAP : path to docker map file.  Contains 1 or more lines like PATH_H:PATH_C which define additional volume mapping
# -P DATAMAP: space-separated list of paths which map to /data1, /data2, etc.
# -j PARALLEL_JOBS: If not MGI mode, specify number of cases to run in parallel.  If not defined, run sequentially, do not use `parallel`
# -M: run in MGI environment
# -o OUTD_BASE_PROJECT: set project output base root directory relative to container.  Defalt is /data1
#   Case analyses will be in OUTD_PROJECT_BASE/CASE

# Submission modes:
# * MGI: launch all case jobs as bsub commands.  Does not block.  Defined if MGI mode (-M)
# * parallel: launch a number of case jobs simultaneously using `parallel`.  Blocks until all jobs finished. Mode is parallel if -j option defined
# * single: run all case jobs sequentially.  Blocks until all jobs finished.  Mode is single if -j option not defined

# Docker mapping paths come from 3 sources:
# * Dockermap.dat - file with list of paths PATH_H:PATH_C
#   Used for mapping BamMap data.  [ -m DOCKERMAP ]
# * Arguments -H and -C - Used for mapping project_config
# * Arbitrary list of paths from [ -P DATAMAP], mapped to /data1, ...
#   Used for mapping arbitrary other paths e.g., reference
#   Passed as arguments to start_docker.sh

# In parallel mode, will use [GNU parallel][1], but script will block until all jobs completed.
# Background on `parallel` and details about blocking / semaphores here:
#     O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#     ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

# Defaults
OUTD_PROJECT_BASE="/data1"
RUN_ARGS=""  # These are arguments passed to start_docker.sh
STEP="all"

while getopts ":dfg:S:p:s:m:P:j:1ML:o:" opt; do
  case $opt in
    d)  # -d is a stack of parameters, each script popping one off until get to -d
      DRYRUN="d$DRYRUN"
      ;;
    f) 
      FORCE_OVERWRITE=1
      ;;
    g) # define LSF_GROUP
      RUN_ARGS="$RUN_ARGS -g $OPTARG"
      ;;
    S) 
      CASELIST=$OPTARG
      >&2 echo "Case List: $CASELIST" 
      ;;
    p) # define LSF_GROUP
      PROJECT_CONFIG="$OPTARG"
      ;;
    s) 
      STEP="$OPTARG"
      ;;
    m) 
      RUN_ARGS="$RUN_ARGS -m $OPTARG"
      ;;
    P)  
      DATAMAP="$OPTARG"
      ;;
    j) 
      PARALLEL_JOBS=$OPTARG
      # See get_unique.sh for details about parallel
      NOW=$(date)
      MYID=$(date +%Y%m%d%H%M%S)
      ;;
    L)  
      LOGD_BASE_PROJECT=$OPTARG
      ;;
    1) 
      >&2 echo "Will stop after one case" 
      JUSTONE=1
      ;;
    M)  
      MGI=1
      RUN_ARGS="$RUN_ARGS -M"
      >&2 echo MGI Mode
      ;;
    o) 
      OUTD_PROJECT_BASE="$OPTARG"
      >&2 echo Project output directory: $OUTD_PROJECT_BASE
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
            >&2 echo Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}

function get_launch_cmd {
    CASE=$1

    NMATCH=$(grep -c $CASE $CASELIST )
    if [ $NMATCH -ne "1" ]; then
        >&2 echo ERROR: CASE $CASE matches $NMATCH lines in $CASELISTSR_H \(expecting unique match\)
        exit 1;
    fi

    CASEDATA=$(grep $CASE $CASELIST)
    # Get what is needed from CaseList
        # CaseList format, from make_case_list.sh:
        #   CASE    - unique name of this tumor/normal sample
        #   SAMPLE_NAME_A - sample name of sample A
        #   PATH_A - container path to data file A
        #   UUID_A - UUID of sample A
        #   SAMPLE_NAME_B - sample name of sample B
        #   PATH_B - container path to data file A
        #   UUID_B - UUID of sample B
    SN_A=$(echo "$CASEDATA" | cut -f 2)
    PATH_A=$(echo "$CASEDATA" | cut -f 3)
    SN_B=$(echo "$CASEDATA" | cut -f 5)
    PATH_B=$(echo "$CASEDATA" | cut -f 6)

    # define output directory for this case and propagate DRYRUN workflow arguments
    ARGS_CASE="-o $OUTD_PROJECT_BASE/$CASE $DRYARG_WORKFLOW -s $STEP"

    # This is the command which will be executed for each CASE in container
    CMD_HOST="bash /BICSEQ2/src/execute_workflow.sh $ARGS_CASE $PROJECT_CONFIG_C $CASE $SN_A $PATH_A $SN_B $PATH_B"

    # Define log path for this case, add dry run policy 
    RUN_ARGS_CASE="$RUN_ARGS $DRYARG_DOCKER -L $LOGD_BASE_PROJECT/$CASE"

    CMD="bash $SCRIPT_PATH/start_docker.sh $RUN_ARGS_CASE -c \"$CMD_HOST\" $DATAMAP "

    echo "$CMD"
}

if [ -z $CASELIST ]; then
    >&2 echo $SCRIPT: ERROR: CaseList file not defined \(-S\)
    exit 1
fi
if [ -z $PROJECT_CONFIG ]; then
    >&2 echo $SCRIPT: ERROR: Project config file not defined \(-p\)
    exit 1
fi
confirm $CASELIST
confirm $PROJECT_CONFIG

# DRYRUN implementation here takes into account that we're calling `start_docker.sh execute_workflow.sh`
# We want successive 'd' in DRYRUN to propagate to called functions as DRYARG_XXX
#   if DRYRUN is blank, execute normally
#   if DRYRUN is 'd', print out call to `start_docker` instead of running it
#   if DRYRUN is 'dd', pass -d to `start_docker`
#   if DRYRUN is 'ddd' and longer, strip off `dd` and pass remainder to `execute_workflow`
DRYARG_DOCKER=""
DRYARG_WORKFLOW=""
if [ -z $DRYRUN ]; then   # DRYRUN not set
    :   # no-op 
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    >&2 echo Dry run in $SCRIPT
elif [ $DRYRUN == "dd" ]; then  # `start_docker.sh -d`
    DRYARG_DOCKER="-d"
else    # DRYRUN has multiple d's: pop two d off the argument and pass it to workflow 
    DRYARG_WORKFLOW="-${DRYRUN%??}"
fi

# this allows us to get CASEs in one of two ways:
# 1: process_cases.sh ... CASE1 CASE2 CASE3
# 2: cat CASES.dat | process_cases.sh ... -
if [ "$1" == "-" ]; then
    CASES=$(cat - )
else
    CASES="$@"
fi

if [ -z "$CASES" ]; then
    >&2 echo ERROR: no case names specified
    exit 1
fi

if [ -z $LOGD_BASE_PROJECT ]; then
    >&2 echo ERROR: Log Base Directory \(-L\) not specified
    exit 1
fi

# We will map PROJECT_CONFIG on host to /project_config.sh in container
PROJECT_CONFIG_C="/project_config.sh"
RUN_ARGS="$RUN_ARGS -H $PROJECT_CONFIG -C $PROJECT_CONFIG_C"

# Loop over all remaining arguments
for CASE in $CASES; do
    >&2 echo Processing CASE $CASE

    # Treat `reset` step separately.  While this could be submitted to run_docker, this it generate warnings
    # because log cannot be written after output directory deleted; also, this will run more quickly on the host.
    if [ "$STEP" == "reset" ]; then
        CMD="rm -rf $LOGD_BASE_PROJECT/$CASE/*"
    else
        CMD=$(get_launch_cmd $CASE)
        test_exit_status

        # OUTD_PROJECT_BASE_HOST
        JOBLOG="$LOGD_BASE_PROJECT/$CASE/execute_workflow.$CASE.log"
        TMPD="$LOGD_BASE_PROJECT/$CASE/tmp"
        mkdir -p $TMPD
        test_exit_status

        if [ $PARALLEL_JOBS ]; then
            CMD="parallel --semaphore -j$PARALLEL_JOBS --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
        fi
    fi

    if [ "$DRYRUN" == "d" ]; then
        >&2 echo Dryrun: $CMD
    else
        >&2 echo Running: $CMD
        eval $CMD
        test_exit_status
    fi

    if [ $JUSTONE ]; then
        break
    fi

done

# this will wait until all jobs completed
if [ $PARALLEL_JOBS ] && [ ! $DRYRUN ]; then
    parallel --semaphore --wait --id $MYID
    test_exit_status
fi


