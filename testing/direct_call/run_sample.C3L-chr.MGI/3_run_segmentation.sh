# Execute segmentation step using tumor/normal as case/control

# Because user directories are mapped on MGI, CONFIG points to the host (rather than container) path to project config file
CONFIG="/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/project_config.run_sample.C3L-chr.MGI.sh"

# MGI-specific setup
export LANG=C


#   bash run_segmentation.sh [options] SAMPLE_NAME.CASE SAMPLE_NAME.CONTROL PROJECT_CONFIG 

# Tip: to debug seg-config file before processing, run with flags -dw,
# check / edit config file as necessary, and run with -C config.txt flag to pass config explicitly

CASE_NAME="C3L-00001"

bash /BICSEQ2/src/run_segmentation.sh $@ -s $CASE_NAME C3L-00001.WGS.T.hg38 C3L-00001.WGS.N.hg38 $CONFIG 

