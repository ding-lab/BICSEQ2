function launch {
    STEP=$1
    F=$2
    NOW=$(date)
    >&2 echo [ $NOW ] Launching $STEP
    bash $STEP $F
    rc=$?
    if [[ $rc != 0 ]]; then
        >&2 echo Fatal ERROR $rc: $!.  Exiting.
        exit $rc;
    fi
}

# Not clear how to propagage -d etc.

#FLAG="-d"
launch 1_get_unique_reads.sh $FLAG
launch 2_run_norm.sh $FLAG
launch 3_run_segmentation.sh $FLAG
launch 4_run_gene_annotation.sh $FLAG

