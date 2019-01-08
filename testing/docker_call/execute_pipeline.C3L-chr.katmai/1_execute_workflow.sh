
# From katmai.BamMap.dat
# C3L-00006.WGS.N.hg38	C3L-00006	UCEC	WGS	blood_normal	/diskmnt/Projects/cptac_downloads_5/GDC_import/data/9f29ebe1-de5d-47a8-a54d-d1e8441409c6/92b5e534-6cb0-43eb-8147-ce7d18526f5e_gdc_realn.bam	220869345161	BAM	hg38	9f29ebe1-de5d-47a8-a54d-d1e8441409c6	katmai
# C3L-00006.WGS.T.hg38	C3L-00006	UCEC	WGS	tumor	/diskmnt/Projects/cptac_downloads_5/GDC_import/data/457f2c4d-ddf3-416e-bb50-b112eede02d5/d9975c5f-288d-417d-bdb3-f490d9a36401_gdc_realn.bam	252294227835	BAM	hg38	457f2c4d-ddf3-416e-bb50-b112eede02d5	katmai

# bash execute_pipeline [options] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM

# Project config must be visible from container
PROJECT_CONFIG="/BICSEQ2/testing/docker_call/execute_pipeline.C3L-chr.katmai/project_config.execute_workflow.C3L-chr.katmai.sh"
CASE_NAME="C3L-00006"
SN_NORMAL="C3L-00006.WGS.N.hg38"
SN_TUMOR="C3L-00006.WGS.T.hg38"

# Assume /data3 maps to /diskmnt/Projects/cptac_downloads_5/GDC_import/data
NORMAL_BAM="/data3/9f29ebe1-de5d-47a8-a54d-d1e8441409c6/92b5e534-6cb0-43eb-8147-ce7d18526f5e_gdc_realn.bam"
TUMOR_BAM="/data3/457f2c4d-ddf3-416e-bb50-b112eede02d5/d9975c5f-288d-417d-bdb3-f490d9a36401_gdc_realn.bam"

CMD="bash /BICSEQ2/src/execute_workflow.sh $@ $PROJECT_CONFIG $CASE_NAME $SN_TUMOR $TUMOR_BAM $SN_NORMAL $NORMAL_BAM"


#  This is if want to use external SEQ files
#   data4:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq  (.seq files)
#  If so, define $IMPORT_SEQ; otherwise, SEQ obtained from pipeline 
#	currently, this is defined in project configuration file

BICSEQ_H="/home/mwyczalk_test/Projects/BICSEQ2"

# See README.md for details.  Paths specific to katmai
bash $BICSEQ_H/src/start_docker.sh $@  -c "$CMD" \
    /diskmnt/Datasets/BICSEQ2-dev.tmp \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/cptac_downloads_5/GDC_import/data \
    /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs

# Tip: run this command within a tmux session for long runs
