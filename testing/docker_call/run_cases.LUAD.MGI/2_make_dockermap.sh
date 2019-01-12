CASES="dat/case_names.dat"
BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat"

OUT="dat/Dockermap.dat"

BICSEQ_H="/gscuser/mwyczalk/projects/BICSEQ2"

bash $BICSEQ_H/src/make_dockermap.sh -b $BAMMAP - < $CASES > $OUT

>&2 echo Written to $OUT
