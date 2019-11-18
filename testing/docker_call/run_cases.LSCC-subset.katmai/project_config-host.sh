# Define host-specific project paths and configuration
# This is for katmai

DISEASE="LSCC"
BATCH_NAME="LSCC-subset"
PROJECT="run_cases.LSCC-subset"

# All paths here are relative to host
BAMMAP="/diskmnt/Projects/cptac_scratch/CPTAC3.workflow/CPTAC3.catalog/BamMap/katmai.BamMap.dat"

# Path to the git repo root
BICSEQ_H="/diskmnt/Projects/cptac_scratch_4/CPTAC3CNV/BICSEQ2/BICSEQ2"

# Principal workflow output directory.  /data1 will map to $OUTD_H
# Change to folder to store output
OUTBASE_H="/diskmnt/Projects/cptac_scratch_4/CPTAC3CNV/BICSEQ2/outputs"
OUTD_H="$OUTBASE_H/$PROJECT"


# Define directories to be mapped to /data2, etc.  If more than DATA4, adjust call to process_cases.sh accordingly
# data2: chrom reference (./hg38) and mappability
DATA2="/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs"
# data3: gene annotation file.  using updated one (19940 lines) copied from MGI
DATA3="/diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs" # /gencode.v29.annotation.hg38.p12.protein_coding.bed

# set this to 1 if running on MGI
IS_MGI=0
MGI_LSF_GROUP="/mwyczalk/BICSEQ2"
