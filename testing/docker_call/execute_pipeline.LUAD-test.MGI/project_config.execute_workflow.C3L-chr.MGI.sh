# Configuration file for testing normalization on MGI
# All paths are container-based
# Should be source-able from host as well 
#
# Assuming the following mapping:
#   data1:/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/PROJECT (output)
#   data2:/gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs  (chrom reference (./hg38) and mappability)
#   data3:/gscmnt/gc2619/dinglab_cptac3/GDC_import/data (BAM files)
#   data4:/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/cached.annotation (gene annotation file)
# 		/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/cached.annotation/gencode.v29.annotation.hg38.p12.bed

# if $IMPORT_SEQ is 1, use external (preprocessed) SEQ file, otherwise
# use directory as defined by workflow.  This is to simplify testing and restarts
# Be careful about inadvertant overwriting of data
IMPORT_SEQ=0

PROJECT="execute_workflow-docker.C3L-00001.MGI"
#CHRLIST="/BICSEQ2/testing/test_data/chromosomes.18-20.dat"
CHRLIST="/BICSEQ2/testing/test_data/chromosomes.dat"

# make perl on MGI be quiet
LANG="C"

# REF defined below is used for two purposes: to get path to all-chrom reference used in prep_mappability step, 
# and for getting the basename of the mappability files ("MER").  For this project, we are not mapping the 
# directory but respecting the reference base name
REF="/foo/GRCh38.d1.vd1.fa"
R=$(basename -- "$REF")
#REF_BASE="${R%.*}"	# this takes trailing .fa off
REF_BASE="${R}"

# This is the root directory of per-chrom reference.  Filename is e.g. chr20.fa
REF_CHR="/data2/hg38"

# All output directories are rooted in $OUTD
OUTD="/data1"

READ_LENGTH=150

# This is used in prep_gene_annotation.sh and run_annotation.sh
GENE_BED="/data4/gencode.v29.annotation.hg38.p12.bed"

SRCD="/BICSEQ2/src"	# scripts directory

# MAPD is passed to make_mappability.sh as OUTD, is mappability file directory
MAPD="/data2"


# This is not ideal way to do this - for example, this statement is printed out every step.
# Better isolate this into separate file
## the path to the .seq file, 
if [ "$IMPORT_SEQ" == 1 ]; then
    SEQD="/data4"
#    >&2 echo "IMPORT_SEQ: will read .seq from $SEQD"
else
    SEQD="$OUTD/unique_reads"
#    >&2 echo "IMPORT_SEQ: will read .seq from workflow $SEQD"
fi

# Output of normalization step
NORMD="$OUTD/norm"
# Output of segmentation step
SEGD="$OUTD/segmentation"
# Output of annotation step
ANND="$OUTD/annotation"

# MER is a convenience string defined in make_mappability.sh
MER=${REF_BASE}.${READ_LENGTH}mer     # common name used for output

# Output filename specifications

# Assumed per-chrom FASTA installed in same directory as $REF
FA_CHR="${REF_CHR}/%s.fa"
# MAPD is identical to OUTD in make_mappability.sh
# v1 defined in main.sh as /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/
MAP_CHR="$MAPD/$MER/$MER.%s.txt"

# get_unique.sh parameters
# SEQ_CHR is used when multiple chrom exist, otherwise SEQ_OUT is used
# SEQ_CHR="$SEQD/$SAMPLE_NAME.%s.seq"
# SEQ_OUT="$SEQD/$SAMPLE_NAME.seq"
# NORM_CHR="$OUTD/${SAMPLE_NAME}.%s.norm.bin" 
# NORM_PDF="$OUTD/${SAMPLE_NAME}.GC.pdf"

# NOte that config file does not know about sequence names
SEQ_CHR="$SEQD/%s_%s.seq"
SEQ_OUT="$SEQD/%s.seq"
NORM_CHR="$NORMD/%s.%s.norm.bin" 
NORM_PDF="$NORMD/%s.GC.pdf"

# See http://compbio.med.harvard.edu/BIC-seq/ for details
BICSEQ_NORM="/NBICseq-norm_v0.2.4/NBICseq-norm.pl"

# Parameters used by BICSEQ_NORM
FRAG_SIZE=350
BIN_SIZE=100

# parameters for segmentation
# LAMBDA is a smoothing parameter
LAMBDA=3
BICSEQ_SEG="/NBICseq-seg_v0.7.2/NBICseq-seg.pl"
SEG_PDF="$SEGD/%s_seg.pdf"  # add to project_config
SEG_CNV="$SEGD/%s.cnv"

# Parameters for annotation step
GL_CASE="$ANND/%s.gene_level.log2.seg"

