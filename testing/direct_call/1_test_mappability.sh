# Run make_mappability.sh from within docker.  Typically, start docker first with 0_start_docker.sh

source project_config.demo.sh

# process test data
bash /BICSEQ2/src/make_mappability.sh $REF $MAPD $CHRLIST
