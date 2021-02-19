#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Usage: make_docker_map.sh [options] SAMPLE [ SAMPLE2 ... ]
#   Calculate a Dockermap file, which provides a list of host / container path mappings, and write to disk
#
# options:
# -b BAMMAP: path to BamMap data file.  Required
#     Format defined here: https://github.com/ding-lab/importGDC/blob/master/make_bam_map.sh
#
# If SAMPLE is - then read SAMPLEs from STDIN
#
# Dockermap is a file with lines of format PATH_H:PATH_C, where PATH_H and PATH_C are
# host and container, paths; data paths of format PATH_H/dir/file.bam are renamed PATH_C/dir/file.bam
# When generating dockermap, for paths of form /A/B/C/D.bam, remove C/D.bam to obtain common path /A/B.  Create Dockermap of all
# such unique paths mapped to /input1, /input2, etc.

SCRIPT=$(basename $0)

while getopts ":b:" opt; do
  case $opt in
    b)  # Required
      BAMMAP="$OPTARG"
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
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

if [ "$#" -lt 1 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo Usage: make_docker_map.sh \[options\] SAMPLE \[SAMPLE2 ...\]
    exit 1
fi

# this allows us to get SAMPLEs in one of two ways:
# 1: start_step.sh ... SAMPLE1 SAMPLE2 SAMPLE3
# 2: cat SAMPLES.dat | start_step.sh ... -
if [ $1 == "-" ]; then
    SAMPLES=$(cat - )
else
    SAMPLES="$@"
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

function process_samples {
    # Loop over all remaining arguments
    for SAMPLE in $SAMPLES
    do
        # If case matches in BamMap, print out paths with the last two elements stripped
        # remove cases where dirname yields "."
        #awk -v c=$SAMPLE 'BEGIN{FS="\t";OFS="\t"}{if ($2 == c ) print $6}' $BAMMAP | xargs dirname {} | xargs dirname {} | grep -v "^.$"
        grep WGS $BAMMAP | awk -v c=$SAMPLE 'BEGIN{FS="\t";OFS="\t"}{if ($1 == c ) print $6}' | xargs dirname {} | xargs dirname {} | grep -v "^.$"
    done
}

# MAP_PATHS are the unique paths of BamMap data
MAP_PATHS=$(process_samples | sort -u)

D=1
for PATH_H in $MAP_PATHS; do

    # container data directories are /import1, /import2, ...
    PATH_C="/import${D}" 

    printf "%s:%s\n" $PATH_H $PATH_C

    let D++
done
