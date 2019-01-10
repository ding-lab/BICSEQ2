BICSEQ2="/gscuser/mwyczalk/projects/BICSEQ2"

CONFIG="project_config.run_sample.C3L-chr.MGI.sh"
source $CONFIG

OUTD="/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/$PROJECT "
>&2 echo Output directory: $OUTD
mkdir -p $OUTD

# See README.md for details.  Paths specific to MGI
bash $BICSEQ2/src/start_docker.sh -M \
    $OUTD \
    /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs \
    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data

# Tip: run this command within a tmux session for long runs
