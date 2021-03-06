# Configuration file for testing normalization on MGI
# All paths are container-based
# Should be source-able from host as well 
#
# This mapping works on katmai
#   data1:/diskmnt/Datasets/BICSEQ2-dev.tmp (output)
#   data2:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  (chrom reference (./hg38) and mappability)
#   data3:/diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs (gene annotation file)
#       /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs/gencode.v29.annotation.hg38.p12.protein_coding.bed


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


READ_LENGTH=150

# This is used in prep_gene_annotation.sh and run_annotation.sh
GENE_BED="/data3/gencode.v29.annotation.hg38.p12.protein_coding.bed"

SRCD="/BICSEQ2/src"	# scripts directory

# MAPD is passed to make_mappability.sh as OUTD, is mappability file directory
MAPD="/data2"


##### Output directory definitions
#
## All output directories are rooted in $OUTD_BASE
# Note, OUTD_BASE must be defined prior to sourcing $PROJECT_CONFIG

# SEQD="/data4"   # might define this if using external data (restart)
SEQD="$OUTD_BASE/unique_reads"

# Output of normalization step
NORMD="$OUTD_BASE/norm"
# Output of segmentation step
SEGD="$OUTD_BASE/segmentation"
# Output of annotation step
ANND="$OUTD_BASE/annotation"
#####


# MER is a convenience string defined in make_mappability.sh
MER=${REF_BASE}.${READ_LENGTH}mer     # common name used for output

# Output filename specifications

# Assumed per-chrom FASTA installed in same directory as $REF
FA_CHR="${REF_CHR}/%s.fa"
# MAPD is identical to OUTD_BASE in make_mappability.sh
# v1 defined in main.sh as /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/
MAP_CHR="$MAPD/$MER/$MER.%s.txt"

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

