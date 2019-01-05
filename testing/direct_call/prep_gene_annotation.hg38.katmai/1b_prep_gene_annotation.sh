# Run make_mappability.sh from within docker.  Typically, start docker first with 0_start_docker.sh

# This requires mapping of data1,2,3,4 as in README.md
# Specific to particular test katmai setup
source project_config.test_norm.katmai.sh
# previously, ../run_sample.C3L-chr.katmai/project_config.run_sample.C3L-chr.katmai.sh

GFF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz"

# Assumes that output directory maps to /data3
BED_OUT="/data3/demo.out/gencode.v29.annotation.hg38.p12.bed"

#   prep_gene_annotation.sh [options] GFF_URL BED_OUT
bash /BICSEQ2/src/prep_gene_annotation.sh $@ $GFF_URL $BED_OUT

