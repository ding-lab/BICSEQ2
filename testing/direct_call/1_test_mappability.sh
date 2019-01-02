# Run make_mappability.sh from within docker.  Typically, start docker first with 0_start_docker.sh

source project_config.demo.sh

# process test data
bash /BICSEQ2/src/make_mappability.sh $REF $MAPD $CHRLIST

# *TODO* be able to test GRCh38 with project_config.sh
# Note that it failed to run, see README.md for output
# GRCh38
# bash make_mappability.sh /data/Reference/GRCh38.d1.vd1.fa /Reference/GRCh38.d1.vd1.fa/mappability
