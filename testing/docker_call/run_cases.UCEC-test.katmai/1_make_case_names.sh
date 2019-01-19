# Make a list of case names
# Specifically, looking for all UCEC cases with WGS hg38 data

source project_config-host.sh

OUT="dat/case_names.dat"

grep UCEC $BAMMAP | grep WGS | grep hg38 | cut -f 2 | sort -u > $OUT
>&2 echo Written to $OUT
