#!/bin/bash

# create mappability indices

# Memory issues:
# Requires > 4Gb memory for GRCh38 (as set on a Mac using Docker Preferences panel); 12Gb works, but `docker stats` suggests ~7Gb is used

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

# OUTD this should be optional, default ./dat

# TODO: write a file indicating path to all mappability files generated.  
# This list will be used in a subsequent step when constructing configuration file

# FASTA Reference should be passed
REF=$1
OUTD=$2 # the output directory
CHROM=$3 # file listing all chromosomes
# Optional arguments
readLength=150 ## the length of the read


if [ ! -e $REF ]; then
	>&2 echo Reference $REF does not exist
	exit 1
fi

if [ -z $OUTD ]; then
	>&2 echo Output directory not defined
	exit 1
fi

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
gem-indexer -i $REF -o ${refFile} -T $THREADS_INDEXER
test_exit_status

## this step needs a lot of CPU to run it fast enough so that not to be killed
# Writes .mappability and .mappability.log
THREADS_MAPPABILITY=4  # Yige had 80
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-mappability **"
gem-mappability -m 2 -I ${refFile}.gem -l ${readLength} -o $MER -T $THREADS_MAPPABILITY &> $MER.mappability.log
test_exit_status

# Writes .wig and .sizes 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-2-wig **"
gem-2-wig -I ${refFile}.gem -i $MER.mappability -o $MER
test_exit_status

# Not cutting sizes file, using as is, as per https://wiki.bits.vib.be/index.php/Create_a_mappability_track

# Writes $MER.bw
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running wigToBigWig **"
wigToBigWig $MER.wig $MER.sizes $MER.bw
test_exit_status

# Writes $MER.bedGraph 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running bigWigToBedGraph **"
bigWigToBedGraph $MER.bw $MER.bedGraph
test_exit_status

# Writes $MER.chr.txt
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Creating mappability files **"
mkdir -p $MER
cd $MER
while read chr; do
    grep ${chr} ../$MER.bedGraph | awk '$4==1 {print $2,$3}' > $MER.${chr}.txt 
done<$CHROM

# This was commended out in Yige's code, but seems relevant...
# bedGraphTobed ${refFile}.${readLength}mer.bedGraph ${refFile}.${readLength}mer.bed 1 ${refFile} ${refFile}.${readLength}mer.uniq.bed
