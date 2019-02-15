source project_config-host.sh

CASES="dat/case_names.dat"
OUT="dat/Dockermap.dat"

bash $BICSEQ_H/src/make_dockermap.sh -b $BAMMAP - < $CASES > $OUT

>&2 echo Written to $OUT
