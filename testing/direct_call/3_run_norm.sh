# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

CONFIG="project_config.demo.sh"

#   bash run_norm.sh [options] SAMPLE_NAME PROJECT_CONFIG 

bash /BICSEQ2/src/run_norm.sh $@ MantaDemo.N $CONFIG 

