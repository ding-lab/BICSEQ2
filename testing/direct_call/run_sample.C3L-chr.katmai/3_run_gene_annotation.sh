# execute run_annotation step on katmai

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"

CASE_NAME="C3L-00008"

bash /BICSEQ2/src/run_annotation.sh $@ $CASE_NAME $CONFIG

