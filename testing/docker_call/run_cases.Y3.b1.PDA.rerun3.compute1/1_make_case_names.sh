# Make a list of case names
# Specifically, looking for all UCEC cases with WGS hg38 data

source project_config-host.sh

mkdir -p dat
OUT="dat/case_names.dat"

grep Y2.b2 $CASEMAP | cut -f 1 | sort -u > $OUT
>&2 echo Written to $OUT
