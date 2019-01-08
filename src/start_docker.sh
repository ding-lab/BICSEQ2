#!/bin/bash
# Start docker container in regular and/or MGI environment, and optionally map given paths to /data1, /data2, ...
# Usage: start_docker.sh [options] [data_path_1 data_path_2 ...]
#
# -M: run in MGI environment
# -d: dry run.  print out docker statement but do not execute
# -I DOCKER_IMAGE: Specify docker image.  Default: mwyczalkowski/bicseq2:latest
# -c cmd: run given command.  default: bash

# data_path will map to /data in container
# TODO: make /data1 be rw, others ro

# TIPS:
# * May want to do `git pull origin maw-dev` in /BICSEQ2
# * To start another terminal in running container, first get name of running container with `docker ps`,
#   then start bash in it with `docker exec -it <container_name> bash`

DOCKER_IMAGE="mwyczalkowski/bicseq2:latest"

LSFQ="-q research-hpc"  # MGI LSF queue.  
CMD="/bin/bash"
while getopts ":MdI:c:" opt; do
  case $opt in
    M)  # example of binary argument
      MGI=1
      >&2 echo MGI Mode
      ;;
    d) 
      DRYRUN="1"
      ;;
    I)
      DOCKER_IMAGE=$OPTARG
      ;;    
    c)
      CMD="$OPTARG"
      ;;    
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
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

# MGI code from https://github.com/ding-lab/importGDC/blob/master/GDC_import.sh
function start_docker_MGI {
CMD="$1"

# Where container's /data is mounted on host
#export LSF_DOCKER_VOLUMES="$ADATD:/data"
export LSF_DOCKER_VOLUMES="$DATMAP"

DCMD="bsub $LSFQ -Is -a \"docker($DOCKER_IMAGE)\" $CMD "
if [ $DRYRUN ]; then
    echo Dryrun: $DCMD
else
    echo Running: $DCMD
    eval $DCMD
fi

}

function start_docker {
# These may be defined at `docker run`-time or prior to executing directly in docker
#JAVA_OPTS="-Xms512m -Xmx512m"
#ENVARGS="-e JAVA_OPTS=\"$JAVA_OPTS\""
CMD=$1

DCMD="docker run $ENVARGS $DATMAP -it $DOCKER_IMAGE $CMD"
if [ $DRYRUN ]; then
    echo Dryrun: $DCMD
else
    echo Running: $DCMD
    eval $DCMD
fi

}

if [ $MGI ]; then
    start_docker_MGI "$CMD"
else
    start_docker "$CMD"
fi

>&2 echo SUCCESS
