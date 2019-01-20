#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# Yige Wu <yigewu@wustl.edu>
# https://dinglab.wustl.edu/

# Start docker container in regular and/or MGI environment, and optionally map given paths to /data1, /data2, ...
# Usage: start_docker.sh [options] [data_path_1 data_path_2 ...]
#
# -M: run in MGI environment
# -L LOGD_H: Log directory on host.  Logs are written to $LOGD_H/log/*.[err|out]
# -d: dry run.  print out docker statement but do not execute
# -I DOCKER_IMAGE: Specify docker image.  Default: mwyczalkowski/bicseq2:latest
# -c CMD: run given command.  default: bash
# -H mntH : additional host mount, may be a file or directory, relative path OK.  If defined, -C must also be defined
# -C mntC : additional container command.  mntH will be mapped to mntC
# -m DOCKERMAP : path to docker map file.  Contains 1 or more lines like PATH_H:PATH_C which define additional volume mapping
# -g LSF_GROUP: LSF group to start in.  MGI mode only

# data_path will map to /data in container
# TODO: make /data1 be rw, others ro
#
# Details about LSF_GROUP: https://github.com/ding-lab/importGDC.CPTAC3
# See also https://confluence.gsc.wustl.edu/pages/viewpage.action?pageId=27592450
# 

SCRIPT=$(basename $0)

DOCKER_IMAGE="mwyczalkowski/bicseq2:latest"

LSFQ="-q research-hpc"  # MGI LSF queue.  
LSF_ARGS=""
DOCKER_CMD="/bin/bash"
INTERACTIVE=1

while getopts ":MdI:c:H:C:L:m:g:" opt; do
  case $opt in
    M)  
      MGI=1
      >&2 echo MGI Mode
      ;;
    L)  
      LOGD_H=$OPTARG
      ;;
    H)  
      MNTH=$OPTARG
      ;;
    C)  
      MNTC=$OPTARG
      ;;
    d) 
      DRYRUN="1"  # Note we do not implement a DRYRUN stack here, since we run -c DOCKER_CMD verbatim
      ;;
    I)
      DOCKER_IMAGE=$OPTARG
      ;;    
    c)
      DOCKER_CMD="$OPTARG"
      INTERACTIVE=0
      ;;    
    m) 
      DOCKERMAP="$OPTARG"
      ;;
    g)
      LSF_ARGS="$LSF_ARGS -g $OPTARG"
      >&2 echo LSF Group: $OPTARG
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR. Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR. Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

D=1
DATMAP=""
# Loop over all arguments, host directories which will be mapped to container directories
for DATDH in "$@"
do
    if [ ! -d $DATDH ]; then
        >&2 echo ERROR: $DATDH is not an existing directory
        exit 1
    fi

    # Using python to get absolute path of DATDH.  On Linux `readlink -f` works, but on Mac this is not always available
    # see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
    ADATDH=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $DATDH)

    # container data directories are /data1, /data2, ...
    DATDC="/data${D}" 

    >&2 echo Mapping $DATDC to $ADATDH
    if [ $MGI ]; then
        DATMAP="$DATMAP $ADATDH:$DATDC"
    else
        DATMAP="$DATMAP -v $ADATDH:$DATDC"
    fi 

    let D++
done

# Exclusive or
if [[ ( $MNTC  && ! $MNTH) || ( ! $MNTC  && $MNTH) ]] ; then
    >&2 echo ERROR: neither or both of -H and -C must be defined
    exit 1
fi

# alternative mounting may be used for e.g. files
if [[ $MNTH ]]; then
    if [ ! -e $MNTH ]; then
        >&2 echo ERROR: $MNTH does not exist
        exit 1
    fi

    AMNTH=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $MNTH)   # get absolute path

    >&2 echo Mapping $MNTC to $AMNTH
    if [ $MGI ]; then
        DATMAP="$DATMAP $AMNTH:$MNTC"
    else
        DATMAP="$DATMAP -v $AMNTH:$MNTC"
    fi 
fi

# Dockermap provides additional ways to map volumes. Expect each line to be passed as if to docker -v
if [ ! -z $DOCKERMAP ]; then
# If defined, dockermap must exist
    if [ ! -e $DOCKERMAP ]; then
        >&2 echo "ERROR: Dockermap \(-m\) $DOCKERMAP does not exist"
        exit 1
    fi

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
        if [ ! -e $PATH_H ]; then
            >&2 echo ERROR: $PATH_H does not exist \( defined in $DOCKERMAP \)
            exit 1
        fi

        if [ $MGI ]; then
            DATMAP="$DATMAP $l"
        else
            DATMAP="$DATMAP -v $l"
        fi
     
    done < $DOCKERMAP
fi

# MGI code from https://github.com/ding-lab/importGDC/blob/master/GDC_import.sh
function start_docker_MGI {
CMD="$1"

# Where container's /data is mounted on host
#export LSF_DOCKER_VOLUMES="$ADATD:/data"
export LSF_DOCKER_VOLUMES="$DATMAP"

# Based on importGDC/GDC_import.sh
if [ $INTERACTIVE == 1 ]; then
    ARGS="-Is"
fi

if [ $LOGD_H ]; then
    mkdir -p $LOGD_H/log
    TS=$(date +%s)
    ERRLOG="$LOGD_H/log/${TS}.err"
    OUTLOG="$LOGD_H/log/${TS}.out"
    LOGS="-e $ERRLOG -o $OUTLOG"
    >&2 echo Writing logs to :
    >&2 echo "   " $OUTLOG
    >&2 echo "   " $ERRLOG
fi

DCMD="bsub $LSFQ $LSF_ARGS $ARGS $LOGS -a \"docker($DOCKER_IMAGE)\" $CMD "
if [ $DRYRUN ]; then
    >&2 echo Dryrun: $DCMD
else
    >&2 echo Running: $DCMD
    eval $DCMD
fi

}

function start_docker {
# These may be defined at `docker run`-time or prior to executing directly in docker
#JAVA_OPTS="-Xms512m -Xmx512m"
#ENVARGS="-e JAVA_OPTS=\"$JAVA_OPTS\""
CMD=$1

if [ $INTERACTIVE == 1 ]; then
    ARGS="-it"
fi

if [ $LOGD_H ]; then
    mkdir -p $LOGD_H/log
    TS=$(date +%s)
    ERRLOG="$LOGD_H/log/${TS}.err"
    OUTLOG="$LOGD_H/log/${TS}.out"
    >&2 echo Writing logs to :
    >&2 echo "   " $OUTLOG
    >&2 echo "   " $ERRLOG
    CMD="$CMD 1>$OUTLOG 2>$ERRLOG"
fi

DCMD="docker run $ENVARGS $DATMAP $ARGS $DOCKER_IMAGE $CMD"
if [ $DRYRUN ]; then
    >&2 echo Dryrun: $DCMD
else
    >&2 echo Running: $DCMD
    eval $DCMD
fi

}

if [ $MGI ]; then
    start_docker_MGI "$DOCKER_CMD"
else
    start_docker "$DOCKER_CMD"
fi

