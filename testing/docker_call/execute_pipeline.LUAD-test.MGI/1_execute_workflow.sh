
# From MGI.BamMap.dat
# C3L-00001.WGS.N.hg38    C3L-00001   LUAD    WGS blood_normal    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam   202924825766    BAM hg38    1d301dc5-ebb2-47e0-9a9f-e31ed41b4542    MGI
# C3L-00001.WGS.T.hg38    C3L-00001   LUAD    WGS tumor   /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam   200258660209    BAM hg38    b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4    MGI

# Project config path is on host, and may be relative. Will be mounted as a file $CONFIG_C
PROJECT_CONFIG_H="./project_config.execute_workflow.C3L-chr.MGI.sh"
source $PROJECT_CONFIG_H

# installation location of this BICSEQ2 project
BICSEQ_H="/gscuser/mwyczalk/projects/BICSEQ2"

# Principal workflow output directory 
OUTBASE_H="/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp"
OUTD_H="$OUTBASE_H/$PROJECT"
>&2 echo Creating output directory $OUTD_H
mkdir -p $OUTD_H

# MGI logs written to output directory
MGI_LOGS="$OUTD_H/mgi.logs"

CASE_NAME="C3L-00001"
SN_NORMAL="C3L-00001.WGS.N.hg38"
SN_TUMOR="C3L-00001.WGS.T.hg38"

# what config will be visible as in container
CONFIG_C="/project_config.sh"


# Assume /data3 maps to  /gscmnt/gc2619/dinglab_cptac3/GDC_import/data
NORMAL_BAM="/data3/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam"
TUMOR_BAM="/data3/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam"

CMD="bash /BICSEQ2/src/execute_workflow.sh $@ $CONFIG_C $CASE_NAME $SN_TUMOR $TUMOR_BAM $SN_NORMAL $NORMAL_BAM"

# -M for MGI
bash $BICSEQ_H/src/start_docker.sh $@ -M -L $MGI_LOGS -H $PROJECT_CONFIG_H -C $CONFIG_C -c "$CMD" \
    $OUTD_H \
    /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs \
    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data \
    /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/cached.annotation

# Tip: run this command within a tmux session for long runs
