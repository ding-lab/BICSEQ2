# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

# Because user directories are mapped on MGI, CONFIG points to the host (rather than container) path to project config file
CONFIG="/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/project_config.run_sample.C3L-chr.MGI.sh"

# MGI-specific setup
export LANG=C

# From MGI.BamMap.dat
# C3L-00001.WGS.N.hg38    C3L-00001   LUAD    WGS blood_normal    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam   202924825766    BAM hg38    1d301dc5-ebb2-47e0-9a9f-e31ed41b4542    MGI
# C3L-00001.WGS.T.hg38    C3L-00001   LUAD    WGS tumor   /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam   200258660209    BAM hg38    b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4    MGI

# Assume /data3 maps to  /gscmnt/gc2619/dinglab_cptac3/GDC_import/data
NORMAL="/data4/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam"
TUMOR="/data4/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam"

#   get_unique.sh [options] SAMPLE_NAME PROJECT_CONFIG BAM

bash /BICSEQ2/src/get_unique.sh $@ C3L-00001.WGS.T.hg38 $CONFIG $TUMOR
bash /BICSEQ2/src/get_unique.sh $@ C3L-00001.WGS.N.hg38 $CONFIG $NORMAL

