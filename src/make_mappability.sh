#!/bin/bash

# Create mappability indices for a reference
# * Reads all-chromosome reference 
# * Generates per-chromosome mappability files 
# * Output filename REF_BASE.READ_LENGTHmer.CHR.txt, e.g., GRCh38.d1.vd1.150mer.chr1.txt
# * The following tools are run on the reference:
#   * gem-indexer 
#   * gem-mappability
#   * gem-2-wig
#   * wigToBigWig
#   * bigWigToBedGraph
# * Output of last step is split into per-chrom mappability files
#   and written to directory REF_BASE.READ_LENGTHmer
# * Several temporary files are generated in the output directory

#
# Usage:
#   bash make_mappability.sh REF OUTD CHRLIST
#   
# REF is full path to reference file
# OUTD is output directory.  Will be created if does not exist
# CHRLIST is list of chromosomes, will be used to create output files
#
# Options:
# -l READ_LENGTH: default = 150
# -r REF_BASE: define alternate REF_BASE.  Default is based on filename of reference
# -o OUT_CHR: string defining output filename, where %s is replaced by string from CHR  
#           Default is ${REF_BASE}.${READ_LENGTH}mer.%s.txt
# -m THREADS_INDEXER: number of threads to be used by gem-indexer [default 4] (Yige had 8)
# -n THREADS_MAPPABILITY: number of threads to be used by gem-indexer [default 16] (Yige had 80)

# Memory issues:
# Requires > 4Gb memory for GRCh38 (as set on a Mac using Docker Preferences panel); 12Gb works, but `docker stats` suggests ~7Gb is used

# Note that project_config file is not read here; rather, relevant parameters passed directly.  

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

# Set defaults
THREADS_INDEXER=4  # Yige had 8
THREADS_MAPPABILITY=16  # Yige had 80
READ_LENGTH=150

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":l:o:m:n:r:" opt; do
  case $opt in
#    d)  # example of binary argument
#      >&2 echo "Dry run"   example
#      CMD="echo"
#      ;;
    l) 
      READ_LENGTH=$OPTARG  
      >&2 echo "Setting read length $READ_LENGTH" 
      ;;
    o) 
      OUT_CHR_ARG=$OPTARG  
      ;;
    m) 
      THREADS_INDEXER=$OPTARG  
      ;;
    n) 
      THREADS_MAPPABILITY=$OPTARG  
      ;;
    r) 
      REF_BASE_ARG=$OPTARG  
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


if [ "$#" -ne 3 ]; then 
    >&2 echo Error: Wrong number of arguments
    exit 1
fi

# FASTA Reference is a file $REFD/$REF_BASE and must exist
REF=$1
OUTD=$2 # the output directory
CHRLIST=$3 # file listing all chromosomes

if [ ! -e $REF ]; then
    >&2 echo Reference $REF does not exist
    exit 1
fi

if [ ! -e $CHRLIST ]; then
    >&2 echo Chromosome list $CHRLIST does not exist
    exit 1
fi

# REF_BASE is typically basename of reference with extension removed, unless
# it is defined otherwise.  Used for naming of output files
if [ $REF_BASE_ARG ]; then
    REF_BASE=$REF_BASE_ARG
else    # https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
    R=$(basename -- "$REF")
    REF_BASE="${R%.*}"
fi
>&2 echo REF_BASE=$REF_BASE    

# common name used for output, e.g., GRCh38.d1.vd1.150mer
MER=${REF_BASE}.${READ_LENGTH}mer     
>&2 echo MER=$MER

# Define format of output filename
if [ $OUT_CHR_ARG ]; then
    OUT_CHR=$OUT_CHR_ARG
else
    OUT_CHR="$MER.%s.txt"
fi

>&2 echo Reference: $REF
>&2 echo Output directory: $OUTD
mkdir -p $OUTD
cd $OUTD

# Writes .gem and .log
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "  ** Running gem-indexer **"
CMD="gem-indexer -i $REF -o $OUTD/$REF_BASE -T $THREADS_INDEXER"
>&2 echo $CMD
>&2 eval $CMD
test_exit_status

## this step needs a lot of CPU to run it fast enough so that not to be killed
# Writes .mappability and .mappability.log
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-mappability **"
CMD="gem-mappability -m 2 -I $OUTD/${REF_BASE}.gem -l ${READ_LENGTH} -o $OUTD/$MER -T $THREADS_MAPPABILITY &> $OUTD/$MER.mappability.log"
>&2 echo $CMD
>&2 eval $CMD
test_exit_status

# Writes .wig and .sizes 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running gem-2-wig **"
CMD="gem-2-wig -I $OUTD/${REF_BASE}.gem -i $OUTD/$MER.mappability -o $MER"
>&2 echo $CMD
>&2 eval $CMD
test_exit_status

# Not cutting sizes file, using as is, as per https://wiki.bits.vib.be/index.php/Create_a_mappability_track

# Writes $MER.bw
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running wigToBigWig **"
CMD="wigToBigWig $OUTD/$MER.wig $OUTD/$MER.sizes $OUTD/$MER.bw"
>&2 echo $CMD
>&2 eval $CMD
test_exit_status

# Writes $MER.bedGraph 
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Running bigWigToBedGraph **"
CMD="bigWigToBedGraph $OUTD/$MER.bw $OUTD/$MER.bedGraph"
>&2 echo $CMD
>&2 eval $CMD
test_exit_status

# Writes $MER.CHR.txt
NOW=$(date)
>&2 echo [ $NOW ]
>&2 echo "      ** Creating mappability files **"
mkdir -p $OUTD/$MER
while read CHR; do
    OUTFN=$OUTD/$MER/$(printf $OUT_CHR $CHR)
    >&2 echo Writing mappability file $OUTFN
    CMD="grep $CHR $OUTD/$MER.bedGraph | awk '\$4==1 {print \$2,\$3}' > $OUTFN"
    #>&2 echo $CMD
    >&2 eval $CMD
done<$CHRLIST

# This was commended out in Yige's code, but seems relevant...
# bedGraphTobed ${REF}.${READ_LENGTH}mer.bedGraph ${REF}.${READ_LENGTH}mer.bed 1 ${REF} ${REF}.${READ_LENGTH}mer.uniq.bed
