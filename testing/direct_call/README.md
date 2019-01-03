# on shiso:
bash 0_start_docker.sh ~/Data

On Katmai:
bash 0_start_docker.sh /diskmnt/Datasets/Reference/GRCh38.d1.vd1/

# Testing of normalization:
For testing of normalization on katmai, using data in 
    ~/Projects/BICSEQ2/testing/BICSEQ2-dev.tmp
bash 0_start_docker.sh ../BICSEQ2-dev.tmp

on MGI, 
bash 0_start_docker.sh -M /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp
