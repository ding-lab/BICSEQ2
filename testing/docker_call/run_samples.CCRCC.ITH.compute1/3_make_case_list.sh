source project_config-host.sh

CASES="dat/case_names.dat"
SAMPLES="dat/tumor_sample_names.dat"
DOCKERMAP="dat/Dockermap.dat"
OUT="dat/CaseList.dat"

#bash $BICSEQ_H/src/make_case_list.sh -b $BAMMAP -m $DOCKERMAP - < $CASES > $OUT
bash $BICSEQ_H/src/make_case_list_bytumorsample.sh -b $BAMMAP -m $DOCKERMAP - < $SAMPLES > $OUT

echo Written to $OUT
