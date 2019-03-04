# Make a list of case names
# Specifically, looking for all GBM cases with WGS hg38 data
# However, for GBM project, we explicitly pass the case list

source project_config-host.sh

OUT="dat/case_names.dat"

# grep GBM $BAMMAP \
#     | grep WGS \
#     | grep hg38 \
#     | cut -f 2 \
#     | sort -u > $OUT
# >&2 echo Written to $OUT
