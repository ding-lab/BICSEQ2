BICSEQ2="/gscuser/mwyczalk/projects/BICSEQ2"

# bash execute_pipeline [options] PROJECT_CONFIG CASE_NAME SN_TUMOR TUMOR_BAM SN_NORMAL NORMAL_BAM
PROJECT_CONFIG="project_config.execute_workflow.C3L-chr.MGI.sh"
source $PROJECT_CONFIG

CASE_NAME="C3L-00006"
SN_NORMAL="C3L-00006.WGS.N.hg38"
SN_TUMOR="C3L-00006.WGS.T.hg38"

# From MGI.BamMap.dat
# C3L-00001.WGS.N.hg38    C3L-00001   LUAD    WGS blood_normal    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam   202924825766    BAM hg38    1d301dc5-ebb2-47e0-9a9f-e31ed41b4542    MGI
# C3L-00001.WGS.T.hg38    C3L-00001   LUAD    WGS tumor   /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam   200258660209    BAM hg38    b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4    MGI

# Assume /data3 maps to  /gscmnt/gc2619/dinglab_cptac3/GDC_import/data
NORMAL_BAM="/data3/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam"
TUMOR_BAM="/data3/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam"

OUTD="/data1/$PROJECT"

LANG="C"
# On MGI, convenient to develop on non-image version 
bash $BICSEQ2/src/execute_workflow.sh $@ -o $OUTD $PROJECT_CONFIG $CASE_NAME $SN_TUMOR $TUMOR_BAM $SN_NORMAL $NORMAL_BAM
