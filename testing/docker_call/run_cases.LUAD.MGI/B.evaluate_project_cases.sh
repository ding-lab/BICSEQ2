# Evaluate processing status for list of cases.  Runs on host

# Usage:
#   B.evaluate_project_cases.sh [options] 
#
# Evaluate status of case processing.  All options passed to src/evaluate_cases.sh
# Reads host-directory log files and output directories to indicate status of each case.  Status may be one of,
#   * ready - ready to begin processing, not yet started
#   * incomplete - processing is being performed
#   * complete - processing has completed
#   * error - processing has completed with an error


PROJECT_CONFIG="./project_config.run_cases.LUAD.MGI.sh"
source $PROJECT_CONFIG

# installation location of this BICSEQ2 project
BICSEQ_H="/gscuser/mwyczalk/projects/BICSEQ2"

# Principal workflow output directory.  this should be defined in project_config-host
OUTBASE_H="/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp"
OUTD_H="$OUTBASE_H/$PROJECT"

CASELIST="dat/CaseList.dat"
DOCKERMAP="dat/Dockermap.dat"

# -M for MGI
bash $BICSEQ_H/src/evaluate_cases.sh -M -L $OUTD_H -p $PROJECT_CONFIG -S $CASELIST $@

