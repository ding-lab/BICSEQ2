BICSEQ2="/home/mwyczalk_test/Projects/BICSEQ2"

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"
source $CONFIG

PROJECT="run_cases.UCEC-test"
OUTBASE_H="/diskmnt/Datasets/BICSEQ2-dev.tmp"
OUTD="$OUTBASE_H/$PROJECT"

# for testing , define outd as for run_cases.UCEC-test
#OUTD="/diskmnt/Datasets/BICSEQ2-dev.tmp/run_sample.C3L-chr.katmai"
>&2 echo Output directory: $OUTD
mkdir -p $OUTD

# data2: chrom reference (./hg38) and mappability
DATA2="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs"
# data3: gene annotation file
DATA3="/diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs"

# See README.md for details.  Paths specific to katmai
bash $BICSEQ2/src/start_docker.sh  $@ \
    $OUTD \
    $DATA2 $DATA3
#    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
#    /diskmnt/Projects/cptac_downloads_3/GDC_import/data \
#    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq

# Tip: run this command within a tmux session for long runs
