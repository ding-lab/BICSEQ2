BICSEQ2="/home/mwyczalk_test/Projects/BICSEQ2"

# See README.md for details.  Paths specific to katmai
bash $BICSEQ2/src/start_docker.sh  \
    /diskmnt/Datasets/BICSEQ2-dev.tmp \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/cptac_downloads_3/GDC_import/data \

# Note that we are reusing Yige's run UCEC.hg38.test for run_uniq
# This is the same as her subsequent runs, e.g., BICSEQ2.UCEC.hg38.121
