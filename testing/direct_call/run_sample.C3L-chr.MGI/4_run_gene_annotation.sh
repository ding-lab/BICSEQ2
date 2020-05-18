# execute run_annotation step on katmai

# Because user directories are mapped on MGI, CONFIG points to the host (rather than container) path to project config file
CONFIG="/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/project_config.run_sample.C3L-chr.MGI.sh"

# MGI-specific setup
LANG=""
PYTHONPATH="" 

CASE_NAME="C3L-00001"

bash /BICSEQ2/src/run_annotation.sh $@ $CASE_NAME $CONFIG

