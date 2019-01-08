IMAGE="mwyczalkowski/bicseq2"

# Build needs to take place in root directory of project 
cd ..
docker build -f docker/Dockerfile -t $IMAGE . 
