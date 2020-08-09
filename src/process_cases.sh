#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'

Launch BICSEQ2 workflow for multiple cases.  Run from host

Usage:
  bash process_cases.sh -S CASE_LIST -p PROJECT_CONFIG [options] CASE [CASE2 ...]

takes list of case names and starts processing on each, calling `execute_workflow CASE`
Reads CaseList to get details (BAM, etc.) for each case.  Runs on host computer
One or more CASEs required.  If CASE is - then read CASE from STDIN

Required options:
-S CASE_LIST: path to CASE LIST data file
-p PROJECT_CONFIG: project configuration file.  Will be mapped to /project_config.sh in container
-L LOGD_PROJECT_BASE: Log base dir relative to host.  Logs of parallel / bsub will be LOGD_PROJECT_BASE/CASE

Optional options
-h: print usage information
-d: dry run: print commands but do not run
    This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
-1 : stop after one case processed.
-f: force overwrite of existing data, if it exists
-s: step to run [ get_unique, normalization, segmentation, annotation, clean, reset, reset-host, all ].  Default is all
-m DOCKERMAP : path to docker map file.  Contains 1 or more lines like PATH_H:PATH_C which define additional volume mapping
-P DATAMAP: space-separated list of paths which map to /data1, /data2, etc.
-M: run in MGI environment
-J PARALLEL_CASES: Specify number of cases to run in parallel.  
   * If not MGI environment, run this many cases at a time using `parallel`.  If not defined, run cases sequentially
   * If in MGI environment, and LSF_GROUP defined, run this many cases at a time; otherwise, run all jobs simultaneously
-g LSF_GROUP: LSF group to use starting job (MGI specific)
      details: https://confluence.ris.wustl.edu/pages/viewpage.action?pageId=27592450
      See also https://github.com/ding-lab/importGDC.CPTAC3
-o OUTD_PROJECT_BASE: set project output base root directory relative to container.  Defalt is /data1
  Case analyses will be in OUTD_PROJECT_BASE/CASE

Submission modes:
* MGI: launch all case jobs as bsub commands.  Does not block, number of jobs to run in parallel is controlled via job groups.  Defined if MGI mode (-M)
* parallel: launch a number of case jobs simultaneously using `parallel` on non-MGI system.  Blocks until all jobs finished. Mode is parallel if -J option defined
* single: run all case jobs sequentially on non-MGI system.  Blocks until all jobs finished.  Mode is single if -J option not defined

Docker mapping paths come from 3 sources:
* Dockermap.dat - file with list of paths PATH_H:PATH_C
  Used for mapping BamMap data.  [ -m DOCKERMAP ]
* Arguments -H and -C - Used for mapping project_config
* Arbitrary list of paths from [ -P DATAMAP], mapped to /data1, ...
  Used for mapping arbitrary other paths e.g., reference
  Passed as arguments to start_docker.sh

reset and reset-host steps are designed to delete all data in case output directory so that successive runs can start 
from a clean state.  Step `reset` removes data by running in a container, while `reset-host` removes data running in 
the host.  The latter is faster but may have permission issues.

EOF

# Background on `parallel` and details about blocking / semaphores here:
#    O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#    ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

# Defaults
OUTD_PROJECT_BASE="/data1"
RUN_ARGS=""  # These are arguments passed to start_docker.sh
STEP="all"

while getopts ":hdfG:g:q:S:p:s:m:P:J:1MZCL:o:" opt; do
  case $opt in
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d)  # -d is a stack of parameters, each script popping one off until get to -d
      DRYRUN="d$DRYRUN"
      ;;
    f) 
      FORCE_OVERWRITE=1
      ;;
    G) # define memory
      MEM_GB="$OPTARG"
      RUN_ARGS="$RUN_ARGS -G $MEM_GB"
      >&2 echo LSF Memory: $MEM_GB GB
      ;;
    g) # define LSF_GROUP
      LSF_GROUP="$OPTARG"
      RUN_ARGS="$RUN_ARGS -g $LSF_GROUP"
      >&2 echo LSF Group: $OPTARG
      ;;
    q) # define LSF_QUEUE
      LSF_QUEUE="$OPTARG"
      RUN_ARGS="$RUN_ARGS -q $LSF_QUEUE"
      >&2 echo LSF QUEUE: $OPTARG
      ;;
    S) 
      CASELIST=$OPTARG
      ;;
    p) 
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
    J) 
      PARALLEL_CASES=$OPTARG
      NOW=$(date)
      MYID=$(date +%Y%m%d%H%M%S)
      ;;
    L)  
      LOGD_PROJECT_BASE=$OPTARG
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
    Z)
      COMPUTE1=1
      RUN_ARGS="$RUN_ARGS -Z"
      >&2 echo COMPUTE1 Mode
      ;;
    o) 
      OUTD_PROJECT_BASE="$OPTARG"
      >&2 echo Project output directory: $OUTD_PROJECT_BASE
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


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

function confirm {
    FN=$1
    if [ ! -s $FN ]; then
        >&2 echo ERROR: $FN does not exist or is empty
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
    RUN_ARGS_CASE="$RUN_ARGS $DRYARG_DOCKER -L $LOGD_PROJECT_BASE/$CASE"

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

>&2 echo Creating output directory $LOGD_PROJECT_BASE
mkdir -p $LOGD_PROJECT_BASE
test_exit_status

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

if [ -z $LOGD_PROJECT_BASE ]; then
    >&2 echo ERROR: Log Base Directory \(-L\) not specified
    exit 1
fi

# set up LSF_GROUPS if appropriate
# If user defines LSF_GROUP in MGI environment, check to make sure this group exists,
# and exit with an error if it does not.  If PARALLEL_CASES is defined, set this as the
# number of jobs which can run at a time
if [ "$MGI" == 1 ] ; then
    >&2 echo Job submission at MGI using bsub
    if [ $LSF_GROUP ] ; then
    # test if LSF Group is valid.  
        >&2 echo Evaluating LSF Group $LSF_GROUP
        LSF_OUT=$( bjgroup -s $LSF_GROUP )
        if [ -z "$LSF_OUT" ]; then
            >&2 echo ERROR: LSF Group $LSF_GROUP does not exist.
            >&2 echo Please create with,
            >&2 echo "   bgadd /mwyczalk/test_group"
            exit 1
        fi
        if [ $PARALLEL_CASES ]; then
            >&2 echo Setting job limit of $PARALLEL_CASES for LSF Group $LSF_GROUP
            bgmod -L $PARALLEL_CASES $LSF_GROUP
            LSF_OUT=$( bjgroup -s $LSF_GROUP )
        fi
        >&2 echo "$LSF_OUT"
        >&2 echo Job limit may be modified with, \`bgmod -L NUMBER_JOBS $LSF_GROUP \`
    fi
else
    if [ -z $PARALLEL_CASES ] ; then
        >&2 echo Running single case at a time \(single mode\)
    else
        >&2 echo Job submission with $PARALLEL_CASES cases in parallel
        PARALLEL_MODE=1
    fi
fi

# set up LSF_GROUPS if appropriate
# If user defines LSF_GROUP in compute1 environment, check to make sure this group exists,
# and exit with an error if it does not.  If PARALLEL_CASES is defined, set this as the
# number of jobs which can run at a time
if [ "$COMPUTE1" == 1 ] ; then
    >&2 echo Job submission at compute1 using bsub
    if [ $LSF_GROUP ] ; then
    # test if LSF Group is valid.
        >&2 echo Evaluating LSF Group $LSF_GROUP
        LSF_OUT=$( bjgroup -s $LSF_GROUP )
        if [ -z "$LSF_OUT" ]; then
            >&2 echo ERROR: LSF Group $LSF_GROUP does not exist.
            >&2 echo Please create with,
            >&2 echo "   bgadd /yigewu/bicseq2"
            exit 1
        fi
        if [ $PARALLEL_CASES ]; then
            >&2 echo Setting job limit of $PARALLEL_CASES for LSF Group $LSF_GROUP
            bgmod -L $PARALLEL_CASES $LSF_GROUP
            LSF_OUT=$( bjgroup -s $LSF_GROUP )
        fi
        >&2 echo "$LSF_OUT"
        >&2 echo Job limit may be modified with, \`bgmod -L NUMBER_JOBS $LSF_GROUP \`
    fi
else
    if [ -z $PARALLEL_CASES ] ; then
        >&2 echo Running single case at a time \(single mode\)
    else
        >&2 echo Job submission with $PARALLEL_CASES cases in parallel
        PARALLEL_MODE=1
    fi
fi

# We will map PROJECT_CONFIG on host to /project_config.sh in container
PROJECT_CONFIG_C="/data4/project_config.sh"
#RUN_ARGS="$RUN_ARGS -H $PROJECT_CONFIG -C $PROJECT_CONFIG_C"

>&2 echo "Iterating over cases in $CASELIST "

# Loop over all remaining arguments
for CASE in $CASES; do
    >&2 echo Processing CASE $CASE

    # Treat `reset-host` step separately.  While this could be submitted to run_docker (as step `reset`), this may generate warnings
    # because log cannot be written after output directory deleted; also, this will run more quickly on the host.
    # however, may have permission issues, when resetting on host,
    if [ "$STEP" == "reset-host" ]; then
        CMD="rm -rf $LOGD_PROJECT_BASE/$CASE/*"
    else
        CMD=$(get_launch_cmd $CASE)
        test_exit_status

        LOGD="$LOGD_PROJECT_BASE/$CASE/log"
        mkdir -p $LOGD
        test_exit_status
        TMPD="$LOGD_PROJECT_BASE/$CASE/tmp"
        mkdir -p $TMPD
        test_exit_status

        if [ $PARALLEL_MODE ]; then
            JOBLOG="$LOGD/process_cases.${CASE}.log"
            CMD=$(echo "$CMD" | sed 's/"/\\"/g' )   # This will escape the quotes in $CMD 
#            CMD="parallel --semaphore -j$PARALLEL_CASES --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
            CMD="parallel -j$PARALLEL_CASES --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
        fi
    fi

    run_cmd "$CMD"

    if [ $JUSTONE ]; then
        break
    fi

done

# this will wait until all jobs completed
if [ $PARALLEL_MODE ] ; then
    CMD="parallel --semaphore --wait --id $MYID"
    run_cmd "$CMD"
fi


