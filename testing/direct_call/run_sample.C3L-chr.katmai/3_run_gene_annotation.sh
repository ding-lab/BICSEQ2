# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"

#   bash run_segmentation.sh [options] SAMPLE_NAME.CASE SAMPLE_NAME.CONTROL PROJECT_CONFIG 

# Tip: to debug norm-config file before processing, run with flags -dw,
# check / edit config file as necessary, and run with -C config.txt flag to pass config explicitly

THIS IS NEW

bash /BICSEQ2/src/run_segmentation.sh $@ -s C3L-00008 C3L-00008_tumor C3L-00008_blood_normal $CONFIG 

