source project_config-host.sh

SAMPLES="dat/tumor_sample_names.dat"

DOCKERMAP="dat/Dockermap.dat"
OUT="dat/"$BATCH_NAME".analysis_description.dat"

bash $BICSEQ_H/src/make_analysis_description_bytumorsample.sh -b $BAMMAP -O $OUTD_H -m $DOCKERMAP - < $SAMPLES > $OUT

echo Written to $OUT
