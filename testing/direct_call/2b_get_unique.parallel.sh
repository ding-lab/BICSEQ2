# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

NORMAL="/data/TestData/MantaDemo/HCC1954.NORMAL.30x.compare.COST16011_region.bam"
TUMOR="/data/TestData/MantaDemo/G15512.HCC1954.1.COST16011_region.bam"
OUTD="/dat"

CHRLIST="../test_data/chromosomes.dat"
bash /BICSEQ2/get_unique.sh $@ -c $CHRLIST -o $OUTD -n MantaDemo.N $NORMAL

CHRLIST="../test_data/chromosomes.8.11.dat"
bash /BICSEQ2/get_unique.sh $@ -c $CHRLIST -o $OUTD -n MantaDemo.T $TUMOR

