CASES="dat/case_names.dat"
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat"

DOCKERMAP="dat/Dockermap.dat"
OUT="dat/CaseList.dat"

BICSEQ_H="/gscuser/mwyczalk/projects/BICSEQ2"

bash $BICSEQ_H/src/make_case_list.sh -b $BAMMAP -m $DOCKERMAP -D CCRCC - < $CASES > $OUT

echo Written to $OUT
