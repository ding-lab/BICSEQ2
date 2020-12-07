source project_config-host.sh

CASES="dat/case_names.dat"

DOCKERMAP="dat/Dockermap.dat"
OUT="dat/CaseList.dat"

bash $BICSEQ_H/src/make_case_list.sh -b $BAMMAP -m $DOCKERMAP - < $CASES > $OUT

echo Written to $OUT
