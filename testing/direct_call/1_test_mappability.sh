# Run make_mappability.sh from within docker.  Typically, start docker first with 0_start_docker.sh

cd ../..

# bash make_mappability.sh /data/Reference/GRCh38.d1.vd1.fa /tmpout

# process test data
FA="/data/TestData/MantaDemo/Homo_sapiens_assembly19.COST16011_region.fa"
OUTD="/tmpout"
CHROM="/BICSEQ2/testing/test_data/chromosomes.8.11.dat"
bash make_mappability.sh $FA $OUTD $CHROM
