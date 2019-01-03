# Debugging calls related to work with Yige.
# From MGI: /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_norm/C3L-00004_tumor_commands.sh

# Yige original call on MGI:
# perl /NBICseq-norm_v0.2.4/NBICseq-norm.pl --tmp=/gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_norm/TMP/ -l 150 -s 350 -b 100 --fig /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_norm/C3L-00004_tumor_GC.pdf /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_norm/C3L-00004_tumor_config.txt /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_norm/C3L-00004_tumor_out.txt


# ../BICSEQ2-dev.tmp is link to /diskmnt/Datasets/BICSEQ2-dev.tmp
# Data for testing of processing from MGI:
#     /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs/hg38/chr20.fa 
#     /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/GRCh38.d1.vd1.fa.150mer.chr20.txt 
#     /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/outputs/CCRCC.hg38.test/run_uniq/C3L-00004_tumor_chr20.seq

perl /NBICseq-norm_v0.2.4/NBICseq-norm.pl --tmp=/data/tmp/ -l 150 -s 350 -b 100 --fig=/data/testout/C3L-00004_tumor_GC.pdf /data/C3L-00004_tumor_config-remapped.txt /data/testout/C3L-00004_tumor_out.txt
