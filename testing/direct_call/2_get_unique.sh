# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

CONFIG="project_config.demo.sh"
NORMAL="/data/TestData/MantaDemo/HCC1954.NORMAL.30x.compare.COST16011_region.bam"
TUMOR="/data/TestData/MantaDemo/G15512.HCC1954.1.COST16011_region.bam"

#   get_unique.sh [options] SAMPLE_NAME PROJECT_CONFIG BAM

bash /BICSEQ2/src/get_unique.sh $@ MantaDemo.N $CONFIG $NORMAL
bash /BICSEQ2/src/get_unique.sh $@ MantaDemo.T $CONFIG $TUMOR

