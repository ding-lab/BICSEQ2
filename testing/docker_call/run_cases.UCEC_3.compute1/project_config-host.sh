# Define host-specific project paths and configuration
# This is for katmai

BATCH_NAME="UCEC_3"
PROJECT="run_cases."$BATCH_NAME

# All paths here are relative to host
BAMMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/CPTAC3.catalog/BamMap/storage1.BamMap.dat"

# The list of case list
CASEMAP="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/CPTAC3.catalog/CPTAC3.cases.dat"

# Installation directory of BICSEQ2.DL
BICSEQ_H="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/scripts/BICSEQ2"

# Principal workflow output directory.  /data1 will map to $OUTD_H
OUTBASE_H="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.UCEC.rerun/outputs"
OUTD_H="$OUTBASE_H/$PROJECT"

# Define directories to be mapped to /data2, etc.  If more than DATA4, adjust call to process_cases.sh accordingly
# data2: chrom reference (./hg38) and mappability
DATA2="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/inputs/"
# data3: gene annotation file.  using updated one (19940 lines) copied from MGI
DATA3="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/Datasets/cached.annotation"
# data4: directory to the scripts for running the current batch, espcially the project config
DATA4=${BICSEQ_H}"/testing/docker_call/run_cases.UCEC_3.compute1"
## data5: directory with all the scripts, including codes under src
DATA5=${BICSEQ_H}

# set this to 1 if running on MGI
IS_MGI=0
MGI_LSF_GROUP="/yigewu/bicseq2"

# set this to 1 if running on Compute1
IS_COMPUTE1=1
COMPUTE1_LSF_GROUP="/yigewu/bicseq2"
