source project_config-host.sh

SAMPLES="dat/tumor_sample_names.dat"
OUT="dat/Dockermap.dat"

#bash $BICSEQ_H/src/make_dockermap.sh -b $BAMMAP - < $CASES > $OUT
bash $BICSEQ_H/src/make_dockermap_bytumorsample.sh -b $BAMMAP - < $SAMPLES > $OUT

>&2 echo Written to $OUT
