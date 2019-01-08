BICSEQ2="/home/mwyczalk_test/Projects/BICSEQ2"

# gene annotation file:
# /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs/gencode.v29.annotation.hg38.p12.protein_coding.bed

# See README.md for details.  Paths specific to katmai
bash $BICSEQ2/src/start_docker.sh  \
    /diskmnt/Datasets/BICSEQ2-dev.tmp \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/cptac_downloads_5/GDC_import/data \
    /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs

# Tip: run this command within a tmux session for long runs
