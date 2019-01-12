# Usage:
#   process_project_cases.sh CASE1 CASE2 ...
# or 
#   cat CASES | process_project_cases.sh -
#
# with CASES a list of case names

# Project config path is on host, and may be relative. Will be mounted as a file /project_config.sh
PROJECT_CONFIG="./project_config.run_cases.LUAD.MGI.sh"
source $PROJECT_CONFIG

# installation location of this BICSEQ2 project
BICSEQ_H="/gscuser/mwyczalk/projects/BICSEQ2"

# Principal workflow output directory 
OUTBASE_H="/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp"
OUTD_H="$OUTBASE_H/$PROJECT"
>&2 echo Creating output directory $OUTD_H
mkdir -p $OUTD_H

CASELIST="dat/CaseList.dat"
DOCKERMAP="dat/Dockermap.dat"

# DATAMAP lists directories mapped to /data1, /data2, etc.
DATAMAP=" $OUTD_H \
    /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs \
    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data \
    /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/cached.annotation"

# -M for MGI
bash $BICSEQ_H/src/process_cases.sh -M -L $OUTD_H -p $PROJECT_CONFIG -S $CASELIST -m $DOCKERMAP $@

