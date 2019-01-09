# Run prep_gene_annotation.sh from within docker.  Typically, start docker first with 0_start_docker.sh

# Because user directories are mapped on MGI, CONFIG points to the host (rather than container) path to project config file
CONFIG="/gscuser/mwyczalk/projects/BICSEQ2/testing/direct_call/run_sample.C3L-chr.MGI/project_config.run_sample.C3L-chr.MGI.sh"
source $CONFIG

# MGI-specific setup
export LANG=C

GFF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz"

# Creates $GENE_BED defined in project_config

#   prep_gene_annotation.sh [options] GFF_URL BED_OUT
bash /BICSEQ2/src/prep_gene_annotation.sh $@ $GFF_URL $GENE_BED

