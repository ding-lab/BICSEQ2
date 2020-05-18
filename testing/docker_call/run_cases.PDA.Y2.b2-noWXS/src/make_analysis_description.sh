#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Usage: make_case_list.sh [options] CASE [ CASE2 ... ]
#   Make a CaseList file, which contains info about tumor/normal input data, which will be input to start_workflow.sh
# options:
# -d: dry run.  This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead, 
#     with each called function called in dry run mode if it gets one -d, and popping off one and passing rest otherwise
# -b BAMMAP: path to BamMap data file.  Required
#     Format defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
# -r REF : filter BAMMAP by reference.  Default: hg38
# -e ES : filter BAMMAP by experimental strategy. Default: WGS
# -A ST_A: sample type of sample A.  Default: tumor
# -B ST_B: sample type of sample B.  Default: blood_normal
# -m DOCKERMAP : remap paths using given docker map file, described below
# -H : supress header in output
#
# If CASE is - then read CASEs from STDIN
#
# CaseList file will have paths which must be accessible from inside docker container; in direct and docker calls, means paths
# must be mapped from host to container paths.  Dockermap is a file with lines of format PATH_H:PATH_C, where PATH_H and PATH_C are
# host and container, paths; data paths of format PATH_H/dir/file.bam are renamed PATH_C/dir/file.bam
# When generating dockermap, for paths of form /A/B/C/D.bam, remove C/D.bam to obtain common path /A/B.  Create Dockermap of all
# such unique paths mapped to /input1, /input2, etc.
# 
# Output format:
#   CASE    - unique name of this tumor/normal sample
#   SAMPLE_NAME_A - sample name of sample A
#   PATH_A - path to data file. Remapped to container path if dockermap is defined
#   UUID_A - UUID of sample A
#   SAMPLE_NAME_B - sample name of sample B
#   PATH_B - path to data file. Remapped to container path if dockermap is defined
#   UUID_B - UUID of sample B

SCRIPT=$(basename $0)

# Default values
REF="hg38"
ES="WGS"
STA="tumor"
STB="blood_normal"
HEADER=1

while getopts ":db:r:e:A:B:O:m:H" opt; do
  case $opt in
    d)  
      DRYRUN=1
      ;;
    b)  # Required
      BAMMAP="$OPTARG"
      ;;
    r) 
      REF="$OPTARG"
      ;;
    e) 
      ES="$OPTARG"
      ;;
    A) 
      STA="$OPTARG"
      ;;
    B) 
      STB="$OPTARG"
      ;;
    m) 
      DOCKERMAP="$OPTARG"
      ;;
    H)  
      HEADER=0
      ;;
    O)
      OUTD="$OPTARG"
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR: Invalid option: -$OPTARG" 
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR: Option -$OPTARG requires an argument." 
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z $BAMMAP ]; then
    >&2 echo ERROR: BamMap file not defined \(-b\)
    exit 1
fi
if [ ! -e $BAMMAP ]; then
    >&2 echo "ERROR: $BAMMAP does not exist"
    exit 1
fi

if [ ! -z $DOCKERMAP ] ; then
# If defined dockermap, the file must exist
    if [ ! -e $DOCKERMAP ]; then
        >&2 echo "ERROR: Dockermap \(-m\) $DOCKERMAP does not exist"
        exit 1
    fi
fi

if [ "$#" -lt 1 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage: make_case_list.sh \[options\] CASE \[CASE2 ...\]
    exit 1
fi

# this allows us to get CASEs in one of two ways:
# 1: start_step.sh ... CASE1 CASE2 CASE3
# 2: cat CASES.dat | start_step.sh ... -
if [ $1 == "-" ]; then
    CASES=$(cat - )
else
    CASES="$@"
fi

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo $SCRIPT: Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}

function remap_path {
    DATPATH=$1
    DOCKERMAP=$2

    # read DOCKERMAP line at a time and remap DATPATH repeatedly
    # DOCKERMAP has lines of format,
    #   PATH_H:PATH_C
    while read l; do
        # Skip comments 
        [[ $l = \#* ]] && continue
        PATH_H=$(echo "$l" | cut -f 1 -d :)
        PATH_C=$(echo "$l" | cut -f 2 -d :)
        if [ -z $PATH_C ] || [ -z $PATH_H ]; then
            >&2 echo ERROR: Bad line in $DOCKERMAP:
            >&2 echo $l
            exit 1
        fi
        # https://stackoverflow.com/questions/12061410/how-to-replace-a-path-with-another-path-in-sed
        DATPATH=$(echo "$DATPATH" | sed "s+^$PATH_H+$PATH_C+") 
    done < $DOCKERMAP
    echo $DATPATH
}

if [ $HEADER == 1 ]; then
    printf "# Case_Name\tOutput_Path\tTumor_Sample_Name\tTumor_BAM_UUID\tNormal_Sample_Name\tNormal_BAM_UUID\n"
fi

# Loop over all remaining arguments
for CASE in $CASES
do

    >&2 echo $SCRIPT: processing $CASE
    # Get samples A and B from BamMap which match filter

    # BamMap columns
    #     1  sample_name
    #     2  case
    #     3  disease
    #     4  experimental_strategy
    #     5  sample_type
    #     6  data_path
    #     7  filesize
    #     8  data_format
    #     9  reference
    #    10  UUID
    #    11  system

    LINE_A=$(awk -v c=$CASE -v ref=$REF -v es=$ES -v st=$STA 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAMMAP)

    if [ -z "$LINE_A" ]; then
	#>&2 echo $LINE_A
        #>&2 echo $CASES
        #>&2 echo $CASE
        >&2 echo ERROR: $REF $CASE $ES $STA sample not found in $BAMMAP
        #exit 1
	continue
    elif [ $(echo "$LINE_A" | wc -l) != "1" ]; then
        >&2 echo WARNING: $REF $CASE $ES $STA sample has multiple matches in $BAMMAP
        >&2 echo Using the first one
        LINE_A=$(echo "$LINE_A" | head -n 1)
    fi    

    SN_A=$(echo "$LINE_A" | cut -f 1)
    PATH_H_A=$(echo "$LINE_A" | cut -f 6)
    UUID_A=$(echo "$LINE_A" | cut -f 10)

    LINE_B=$(awk -v c=$CASE -v ref=$REF -v es=$ES -v st=$STB 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c && $4 == es && $5 == st && $9 == ref) print}' $BAMMAP)
    if [ -z "$LINE_B" ]; then
        >&2 echo ERROR: $REF $CASE $ES $STB sample not found in $BAMMAP
        #exit 1
	continue
    elif [ $(echo $LINE_B | wc -l) != "1" ]; then
        >&2 echo WARNING: $REF $CASE $ES $STB sample has multiple matches in $BAMMAP
        >&2 echo Using the first one
        LINE_B=$(echo "$LINE_B" | head -n 1)
    fi    
    
    SN_B=$(echo "$LINE_B" | cut -f 1)
    PATH_H_B=$(echo "$LINE_B" | cut -f 6)
    UUID_B=$(echo "$LINE_B" | cut -f 10)

    if [ $DOCKERMAP ]; then
        PATH_C_A=$(remap_path $PATH_H_A $DOCKERMAP)
        test_exit_status
        PATH_C_B=$(remap_path $PATH_H_B $DOCKERMAP)
        test_exit_status
    else
        PATH_C_A=$PATH_H_A
        PATH_C_B=$PATH_H_B
    fi

    PATH_OUT=$OUTD"/"$CASE"/annotation/"$CASE".gene_level.log2.seg"

    printf "$CASE\t$PATH_OUT\t$SN_A\t$UUID_A\t$SN_B\t$UUID_B\n"

done
