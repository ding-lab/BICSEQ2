# Start docker container and map given path to /data
# Usage: 0_start_docker.sh data_path
# data_path will map to /data in container

IMAGE="mwyczalkowski/bicseq2:latest"

if [ "$#" -ne 1 ]; then
    >&2 echo Usage: 0_start_docker.sh data_path
    exit 1
fi

DATD=$1
if [ ! -d $DATD ]; then
    >&2 echo Error: $DATD is not an existing directory
    exit 1
fi

# These may be defined at `docker run`-time or prior to executing mutect directly in docker
#JAVA_OPTS="-Xms512m -Xmx512m"
#ENVARGS="-e JAVA_OPTS=\"$JAVA_OPTS\""

# Using python to get absolute path of DATD.  On Linux `readlink -f` works, but on Mac this is not always available
# see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
ADATD=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $DATD)

docker run $ENVARGS -v $ADATD:/data -it $IMAGE /bin/bash

# TIPS:

# To start another terminal in running container, first get name of running container with `docker ps`,
# then start bash in it with,
# `docker exec -it <container_name> bash`
