#!/bin/bash

# create mappability indices

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal error.  Exiting.
            exit $rc;
        fi;
    done
}


# FASTA Reference should be passed
REF=$1
OUTD=$2 # the output directory
CHROM=$3 # file listing all chromosomes

if [ ! -e $REF ]; then
	>&2 echo Reference $REF does not exist
	exit 1
fi

if [ -z $OUTD ]; then
	>&2 echo Output directory not defined
	exit 1
fi

# Optional arguments
readLength=150 ## the length of the read

## get and split and reference fasta file
if [ ! -e $REF ]; then
	echo "Error: Reference $REF does not exist"
    exit 1
fi
# refFile="GRCh38.d1.vd1.fa"
# refFile is used for naming of various outputs.  Assigning it based on REF
refFile=$(basename $REF)
MER=${refFile}.${readLength}mer     # common name used for output


>&2 echo Reference: $REF
>&2 echo Output directory: $OUTD
mkdir -p $OUTD
cd $OUTD

# Writes .gem and .log
THREADS_INDEXER=4  # Yige had 8
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "	** Running gem-indexer **"

echo Skipping gem-indexer

# gem-indexer -i $REF -o ${refFile} -T $THREADS_INDEXER
test_exit_status

## this step needs a lot of CPU to run it fast enough so that not to be killed
# Writes .mappability and .mappability.log
THREADS_MAPPABILITY=2  # Yige had 80
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-mappability **"
#gem-mappability -m 2 -I ${refFile}.gem -l ${readLength} -o $MER -T $THREADS_MAPPABILITY &> $MER.mappability.log
echo gem-mappability -m 2 -I ${refFile}.gem -l ${readLength} -o $MER -T $THREADS_MAPPABILITY 


gem-mappability -m 2 -I GRCh38.d1.vd1.fa.gem -l 150 -o GRCh38.d1.vd1.fa.150mer -T 1

test_exit_status
exit

# Writes .wig and .sizes 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-2-wig **"
gem-2-wig -I ${refFile}.gem -i $MER.mappability -o $MER
test_exit_status

## cut the wig file starting from the line containing CMV
awk -F ' ' '{print $1, $3}' $MER.sizes | grep -v gi > $MER.sizes.cut
test_exit_status

# Writes $MER.bw
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running wigToBigWig **"
wigToBigWig $MER.wig.cut $MER.sizes.cut $MER.bw
test_exit_status

# Writes $MER.bedGraph 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running bigWigToBedGraph **"
bigWigToBedGraph $MER.bw $MER.bedGraph
test_exit_status

# Writes $MER.bed
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo Running loop over chrom which will die
mkdir -p ${refFile}.${readLength}mer
cd ${refFile}.${readLength}mer
while read chr; do
    grep ${chr} ../${refFile}.${readLength}mer.bedGraph | awk '$4==1 {print $2,$3}' > ${refFile}.${readLength}mer.${chr}.txt 
done<$CHROM

# This was commended out in Yige's code, but seems relevant...
# bedGraphTobed ${refFile}.${readLength}mer.bedGraph ${refFile}.${readLength}mer.bed 1 ${refFile} ${refFile}.${readLength}mer.uniq.bed
