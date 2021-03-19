# start processing of list of cases

# Usage:
#   A.process_project_cases.sh [options] CASE1 CASE2 ...
# or 
#   cat CASES | A.process_project_cases.sh [options] -
#
# with CASES a list of case names.  All options passed to src/process_cases.sh

# Project config path is on host, and may be relative. Will be mounted as a file /project_config.sh
PROJECT_CONFIG="./project_config.sh"
source project_config-host.sh

CASELIST="dat/CaseList.dat"
DOCKERMAP="dat/Dockermap.dat"

# DATAMAP lists directories mapped to /data1, /data2, etc.
DATAMAP=" $OUTD_H $DATA2 $DATA3 $DATA4 $DATA5"

if [ $IS_MGI == 1 ]; then
    # -M for MGI
    MGI_ARGS="-M -g $MGI_LSF_GROUP -q research-hpc"
fi

if [ $IS_COMPUTE1 == 1 ]; then
    # -M for MGI
    COMPUTE1_ARGS="-Z -g $COMPUTE1_LSF_GROUP -q general -G 100"
fi

# If PARALLEL_CASES is not defined, on non-MGI run jobs sequentially
PARALLEL_CASES=15; PARGS="-J $PARALLEL_CASES"

bash $BICSEQ_H/src/process_cases.sh $MGI_ARGS $COMPUTE1_ARGS $PARGS -L $OUTD_H -p $PROJECT_CONFIG -S $CASELIST -m $DOCKERMAP -P "$DATAMAP" $@

#Required options:
#-S CASE_LIST: path to CASE LIST data file
#-p PROJECT_CONFIG: project configuration file.  Will be mapped to /project_config.sh in container
#-L LOGD_PROJECT_BASE: Log base dir relative to host.  Logs of parallel / bsub will be LOGD_PROJECT_BASE/CASE

#Optional options
#-h: print usage information
#-d: dry run: print commands but do not run
#    This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
#-1 : stop after one case processed.
#-f: force overwrite of existing data, if it exists
#-s: step to run [ get_unique, normalization, segmentation, annotation, clean, reset, reset-host, all ].  Default is all
## clean: redo the compressing the output directories and deleting the original directories
#-m DOCKERMAP : path to docker map file.  Contains 1 or more lines like PATH_H:PATH_C which define additional volume mapping
#-P DATAMAP: space-separated list of paths which map to /data1, /data2, etc.
#-M: run in MGI environment
#-J PARALLEL_CASES: Specify number of cases to run in parallel.
#   * If not MGI environment, run this many cases at a time using `parallel`.  If not defined, run cases sequentially
#   * If in MGI environment, and LSF_GROUP defined, run this many cases at a time; otherwise, run all jobs simultaneously
#-g LSF_GROUP: LSF group to use starting job (MGI specific)
#      details: https://confluence.ris.wustl.edu/pages/viewpage.action?pageId=27592450
#      See also https://github.com/ding-lab/importGDC.CPTAC3
#-o OUTD_PROJECT_BASE: set project output base root directory relative to container.  Defalt is /data1
#  Case analyses will be in OUTD_PROJECT_BASE/CASE

#reset and reset-host steps are designed to delete all data in case output directory so that successive runs can start
#from a clean state.  Step `reset` removes data by running in a container, while `reset-host` removes data running in
#the host.  The latter is faster but may have permission issues.
