# Define host-specific project paths and configuration
# This is for katmai

PROJECT="run_cases.UCEC-test"

# All paths here are relative to host
BAMMAP="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat"

# Installation directory of BICSEQ2.DL
BICSEQ_H="/home/mwyczalk_test/Projects/BICSEQ2"

# Principal workflow output directory.  /data1 will map to $OUTD_H
OUTBASE_H="/diskmnt/Datasets/BICSEQ2-dev.tmp"
OUTD_H="$OUTBASE_H/$PROJECT"


# Define directories to be mapped to /data2, etc.  If more than DATA4, adjust call to process_cases.sh accordingly
# data2: chrom reference (./hg38) and mappability
DATA2="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs"
# data3: gene annotation file
DATA3="/diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs"

# set this to 1 if running on MGI
IS_MGI=0
MGI_LSF_GROUP="/mwyczalk/BICSEQ2"
