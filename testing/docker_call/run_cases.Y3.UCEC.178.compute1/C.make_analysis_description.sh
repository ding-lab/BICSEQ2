source project_config-host.sh

CASES="dat/case_names.dat"

DOCKERMAP="dat/Dockermap.dat"
OUT="dat/"$BATCH_NAME".analysis_description.dat"

bash $BICSEQ_H/src/make_analysis_description.sh -b $BAMMAP -O $OUTD_H -m $DOCKERMAP - < $CASES > $OUT

echo Written to $OUT
