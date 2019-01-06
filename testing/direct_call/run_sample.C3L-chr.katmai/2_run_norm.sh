# Execute normalization step on two samples on katmai

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"

# Tip: to debug norm-config file before processing, run with flags -dw,
# check / edit config file as necessary, and run with -C config.txt flag to pass config explicitly

#   bash run_norm.sh [options] SAMPLE_NAME PROJECT_CONFIG 
bash /BICSEQ2/src/run_norm.sh $@ C3L-00008_tumor $CONFIG 
bash /BICSEQ2/src/run_norm.sh $@ C3L-00008_blood_normal $CONFIG 

