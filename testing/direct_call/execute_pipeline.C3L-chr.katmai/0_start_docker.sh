BICSEQ2="/home/mwyczalk_test/Projects/BICSEQ2"

# gene annotation file:
# /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs/gencode.v29.annotation.hg38.p12.protein_coding.bed

CONFIG="project_config.execute_pipeline.C3L-chr.katmai.sh"
source $CONFIG

OUTD="/diskmnt/Datasets/BICSEQ2-dev.tmp/run_sample.C3L-chr.katmai"
>&2 echo Output directory: $OUTD
mkdir -p $OUTD
# See README.md for details.  Paths specific to katmai
bash $BICSEQ2/src/start_docker.sh $@  \
    $OUTD \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/cptac_downloads_5/GDC_import/data \
    /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs

# Tip: run this command within a tmux session for long runs
