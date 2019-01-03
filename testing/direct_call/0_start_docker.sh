#!/bin/bash
# Start docker container in regular and/or MGI environment, and map given path to /data1, /data2, ...
# Usage: 0_start_docker.sh [options] data_path_1 [data_path_2 ...]
#
# -M: run in MGI environment
# -d: dry run.  print out docker statement but do not execute
# -I DOCKER_IMAGE: Specify docker image.  Default: mwyczalkowski/bicseq2:latest

# data_path will map to /data in container

# TIPS:
# * May want to do `git pull origin maw-dev` in /BICSEQ2
# * To start another terminal in running container, first get name of running container with `docker ps`,
#   then start bash in it with `docker exec -it <container_name> bash`

DOCKER_IMAGE="mwyczalkowski/bicseq2:latest"

LSFQ="-q research-hpc"  # MGI LSF queue.  
while getopts ":MdI:" opt; do
  case $opt in
    M)  # example of binary argument
      MGI=1
      >&2 echo MGI Mode
      ;;
    d) 
      DRYRUN=1
      ;;
    I)
      DOCKER_IMAGE=$OPTARG
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

if [ "$#" -lt 1 ]; then
    >&2 echo Usage: 0_start_docker.sh data1_path \[data2_path...\]
    exit 1
fi

D=1
DATMAP=""
# Loop over all arguments, host directories which will be mapped to container directories
for DATDH in "$@"
do
    if [ ! -d $DATDH ]; then
        >&2 echo Error: $DATDH is not an existing directory
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

# Where container's /data is mounted on host
#export LSF_DOCKER_VOLUMES="$ADATD:/data"
export LSF_DOCKER_VOLUMES="$DATMAP"

CMD="bsub $LSFQ -Is -a \"docker($DOCKER_IMAGE)\" /bin/bash "
if [ $DRYRUN ]; then
    echo Dryrun: $CMD
else
    echo Running: $CMD
    eval $CMD
fi

}

function start_docker {
# These may be defined at `docker run`-time or prior to executing directly in docker
#JAVA_OPTS="-Xms512m -Xmx512m"
#ENVARGS="-e JAVA_OPTS=\"$JAVA_OPTS\""

CMD="docker run $ENVARGS $DATMAP -it $DOCKER_IMAGE /bin/bash"
if [ $DRYRUN ]; then
    echo Dryrun: $CMD
else
    echo Running: $CMD
    eval $CMD
fi

}

if [ $MGI ]; then
    start_docker_MGI
else
    start_docker
fi
