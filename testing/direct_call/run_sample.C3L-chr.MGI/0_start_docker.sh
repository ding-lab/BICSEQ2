BICSEQ2="/gscuser/mwyczalk/projects/BICSEQ2"

# See README.md for details.  Paths specific to MGI
bash $BICSEQ2/src/start_docker.sh -M \
    /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp \
    /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs \
    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data

# Tip: run this command within a tmux session for long runs
