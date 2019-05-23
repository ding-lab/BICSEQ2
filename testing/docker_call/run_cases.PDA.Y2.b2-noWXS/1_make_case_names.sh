# Make a list of case names
# Specifically, looking for all UCEC cases with WGS hg38 data

source project_config-host.sh

mkdir -p dat
OUT="dat/case_names.dat"

#grep Y2.b1 $CASEMAP | cut -f 1 | sort -u > $OUT
grep PDA /diskmnt/Projects/Users/dcui/Projects/Fusion_hg38/Data_locations/CPTAC3.catalog/katmai.BamMap.dat | grep WGS | cut -f 2 | sort | uniq > $OUT
>&2 echo Written to $OUT
