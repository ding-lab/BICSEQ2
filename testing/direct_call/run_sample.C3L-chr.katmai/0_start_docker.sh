BICSEQ2="/home/mwyczalk_test/Projects/BICSEQ2"

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"
source $CONFIG

OUTD="/diskmnt/Datasets/BICSEQ2-dev.tmp/run_sample.C3L-chr.katmai"
>&2 echo Output directory: $OUTD
mkdir -p $OUTD

# See README.md for details.  Paths specific to katmai
bash $BICSEQ2/src/start_docker.sh  $@ \
    $OUTD \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/cptac_downloads_3/GDC_import/data \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq

# Tip: run this command within a tmux session for long runs
