# Make a list of case names
# Specifically, looking for all LUAD cases with WGS hg38 data

BAMMAP="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat"
OUT="dat/case_names.dat"

grep LUAD $BAMMAP | grep WGS | grep hg38 | cut -f 2 | sort -u > $OUT
>&2 echo Written to $OUT
