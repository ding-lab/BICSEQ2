# Execute normalization step on two samples on katmai

# Because user directories are mapped on MGI, CONFIG points to the host (rather than container) path to project config file
CONFIG="/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/project_config.run_sample.C3L-chr.MGI.sh"

# MGI-specific setup
export LANG=C

# Tip: to debug norm-config file before processing, run with flags -dw,
# check / edit config file as necessary, and run with -C config.txt flag to pass config explicitly

#   bash run_norm.sh [options] SAMPLE_NAME PROJECT_CONFIG 

bash /BICSEQ2/src/run_norm.sh $@ C3L-00001.WGS.T.hg38 $CONFIG 
bash /BICSEQ2/src/run_norm.sh $@ C3L-00001.WGS.N.hg38 $CONFIG 

