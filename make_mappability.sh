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


>&2 echo Output directory: $OUTD
mkdir -p $OUTD
cd $OUTD

# Writes $MER.gem
echo gem-indexer -i $REF -o ${refFile} -T 8
test_exit_status
exit

## this step needs a lot of CPU to run it fast enough so that not to be killed
# Writes $MER.mappability
gem-mappability -m 2 -I ${refFile}.gem -l ${readLength} -o $MER -T 80 &> $MER.mappability.log
test_exit_status

# Writes $MER.wig ?
gem-2-wig -I ${refFile}.gem -i $MER.mappability -o $MER
test_exit_status

## cut the wig file starting from the line containing CMV
awk -F ' ' '{print $1, $3}' $MER.sizes | grep -v gi > $MER.sizes.cut
test_exit_status

# Writes $MER.bw
wigToBigWig $MER.wig.cut $MER.sizes.cut $MER.bw
test_exit_status

# Writes $MER.bedGraph 
bigWigToBedGraph $MER.bw $MER.bedGraph
test_exit_status

# Writes $MER.bed

mkdir -p ${refFile}.${readLength}mer
cd ${refFile}.${readLength}mer
while read chr; do
    grep ${chr} ../${refFile}.${readLength}mer.bedGraph | awk '$4==1 {print $2,$3}' > ${refFile}.${readLength}mer.${chr}.txt 
done<$CHROM

# This was commended out in Yige's code, but seems relevant...
# bedGraphTobed ${refFile}.${readLength}mer.bedGraph ${refFile}.${readLength}mer.bed 1 ${refFile} ${refFile}.${readLength}mer.uniq.bed
