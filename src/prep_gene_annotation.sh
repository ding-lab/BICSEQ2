# Based on cdde from Yige Wu

# Download annotation GFF file and process it to obtain gene annotation BED file
# Usage:
#   bash prep_gene_annotation.sh [options] GFF_URL BED_OUT

# Input: 
#   URL of gff
#   filename of output
# Output:
#   Writes to output file
#   Temp directory in output file path, or specified independently
#
# Options:
# -d: dry run
# -n: do not delete temporary downloaded GFF file
# 
# TODO:
# Checks to see if output file exists before overwriting
#   Option to force overwrite even if output exists

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

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":dn" opt; do
  case $opt in
    d)  
      DRYRUN=1
      ;;
    n)  
      NORMGZ=1
      ;;
#    l)   # example
#      READ_LENGTH=$OPTARG  
#      ;;
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


if [ "$#" -ne 2 ]; then 
    >&2 echo Error: Wrong number of arguments
    exit 1
fi

GFF_URL=$1
BED_OUT=$2

# expand out the path of $BED_OUT and save to DESTD
DESTD=$(dirname $(readlink -f $BED_OUT) )

>&2 echo Output directory $DESTD
cd $DESTD

GFF=$(basename $GFF_URL)
if [ -e $GFF ]; then
    echo Note: Target exists: $GFF
    echo Skipping download...
else
    >&2 echo Getting $GFF_URL
    wget $GFF_URL
fi


# Past data:
# 
# GFF_URL=ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gff3.gz
# ## the filename of the gene annotation GFF3 file
# geneAnnoGFF3File=gencode.v29.annotation.gff3
# ## the filename of the gene annotation bed file
# geneAnnoBedFile=gencode.v29.annotation.hg38.p12.bed
# path: /diskmnt/Projects/CPTAC3CNV/gatk4wxscnv/inputs

PATH="$PATH:/bedops/bin"
>&2 echo Processing $GFF

CMD="zcat $DESTD/$GFF | awk '\$3==\"gene\"' | convert2bed -i gff - | cut -f 1,2,3,10 | awk -F ';|\\t' '{print \$1,\$2,\$3,\$7}' | awk -F ' |\\=' '{print \$1,\$2,\$3,\$5}' OFS='\t' > $BED_OUT"
if [ $DRYRUN ]; then
    >&2 echo Dryrun: $CMD
else
    >&2 echo Running: $CMD
    eval $CMD
    test_exit_status
    >&2 echo Successfully written to $BED_OUT
fi

if [ ! $NORMGZ ]; then
# "No rm gz" is not set
    >&2 echo Deleting temporary file $DESTD/$GFF
    rm -f $DESTD/$GFF
fi
