# Run prep_gene_annotation.sh from within docker.  Typically, start docker first with 0_start_docker.sh

# Using same project_config as other katmai steps.  In particular, writing output to /data3/demo.out
source project_config.run_sample.C3L-chr.katmai.sh

# previously, ../run_sample.C3L-chr.katmai/project_config.run_sample.C3L-chr.katmai.sh

GFF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz"

# Assumes that output directory maps to /data3
BED_OUT="/data3/demo.out/gencode.v29.annotation.hg38.p12.bed"

#   prep_gene_annotation.sh [options] GFF_URL BED_OUT
bash /BICSEQ2/src/prep_gene_annotation.sh $@ $GFF_URL $BED_OUT

