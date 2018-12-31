# Configuration file which defines project parameters
# Includes all files which are "passed" from one step to the next

# Output of normalization step
NORMD=$OUTD/norm

# MAPD is passed to make_mappability.sh as OUTD, is mappability file directory
MAPD=$OUTD/map

## the path to the .seq file, generated by run_uniq step
SEQD=$OUTD/seq

READ_LENGTH=150

## the path to the by chromosome fasta file
REFD="/diskmnt/Datasets/Reference/GRCh38.d1.vd1/"

# It is assumed that both the complete reference and the per-chrom references are in $REFD
# Reference base name
REF="GRCh38.d1.vd1.fa"

# MER is a convenience string defined in make_mappability.sh
MER=${REF}.${READ_LENGTH}mer     # common name used for output


FA_CHR="${REFD}/${REF}%s.fa"
# MAPD is identical to OUTD in make_mappability.sh
# v1 defined in main.sh as /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer/
MAP_CHR="$MAPD/$MER.%s.txt"

# get_unique.sh parameters
# SEQ_CHR is used when multiple chrom exist, otherwise SEQ_OUT is used
SEQ_CHR="$SEQD/$SAMPLE_NAME.%s.seq"
SEQ_OUT="$SEQD/$SAMPLE_NAME.seq"

NORM_CHR="$OUTD/${SAMPLE_NAME}.%s.norm.bin" 
NORM_PDF="$OUTD/${SAMPLE_NAME}.GC.pdf"

# See http://compbio.med.harvard.edu/BIC-seq/ for details
BICSEQ_NORM="/NBICseq-norm_v0.2.4/NBICseq-norm.pl"
# Parameters used by BICSEQ_NORM
FRAG_SIZE=350
BIN_SIZE=100
