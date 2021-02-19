# Evaluate processing status for list of cases.  Runs on host

# Usage:
#   B.evaluate_project_cases.sh [options] 
#
# Evaluate status of case processing.  All options passed to src/evaluate_cases.sh
# Reads host-directory log files and output directories to indicate status of each case.  Status may be one of,
#   * not_started - ready to begin processing, not yet started
#   * running - processing is being performed
#   * complete - processing has completed
#   * error - processing has completed with an error

PROJECT_CONFIG="./project_config.sh"
source project_config-host.sh

CASELIST="dat/CaseList.dat"

# -M for MGI
bash $BICSEQ_H/src/evaluate_tumorsamples.sh -M -L $OUTD_H -p $PROJECT_CONFIG -S $CASELIST $@

