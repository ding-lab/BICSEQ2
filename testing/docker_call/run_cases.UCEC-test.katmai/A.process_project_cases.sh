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
DATAMAP=" $OUTD_H $DATA2 $DATA3 $DATA4 "

if [ $IS_MGI == 1 ]; then
    # -M for MGI
    MGI_ARGS="-M -g $MGI_LSF_GROUP"
fi

# If PARALLEL_CASES is not defined, on non-MGI run jobs sequentially
if [ ! -z $PARALLEL_CASES ]; then
    PARGS="-J $PARALLEL_CASES"
fi

bash $BICSEQ_H/src/process_cases.sh $MGI_ARGS $PARGS -L $OUTD_H -p $PROJECT_CONFIG -S $CASELIST -m $DOCKERMAP -P "$DATAMAP" $@

