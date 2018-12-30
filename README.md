BIC-Seq source: http://compbio.med.harvard.edu/BIC-seq/
BICSEQ2 github project: https://github.com/ding-lab/BICSEQ2

Background reading on creating mappability track:
    https://wiki.bits.vib.be/index.php/Create_a_mappability_track

Note that there seems to be newer version here: https://github.com/smarco/gem3-mapper
Yige says that it does not have some required features implemented.


Steps from main.pl

1. get_dependencies.sh
  * Stages chromosomes.txt
  * git clone CPTAC3.catalog
  * wget NBICseq-norm_v0.2.4.tar.gz
  * wget NBICseq-seg_v0.7.2.tar.gz
  * obtain samtools-0.1.7a_getUnique-0.1.3
  * stages reference (copy)
  * stages per-chrom reference (wget)
  * makes "mappability file".
    * tests for and generates data produced by the following:
      * gem-indexer     - included in gem libraries
      * gem-mappability - included in gem libraries
      * gem-2-wig       - included in gem libraries
      * wigToBigWig  
      * bigWigToBedGraph 
    * Mappability file format: ${refFile}.${readLength}mer.chr20.txt
  * Output on katmai here: /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs

2. run_uniq
  * Filters BAM file through custom "unique" filter to create .seq files
    * BICSEQ1 Documentation states, `Get the uniquely mapped reads from the bam file (you may use the modified samtools as provided [here]).`
    * http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz)
  * implements GNU parallel calls
  * is not a functioning script due to debug (?) exit call

3. run_norm
  * writes config and command files, the latter which calls BICSeq2/NBICseq-norm_v0.2.4/NBICseq-norm.pl
  * Documentation: http://compbio.med.harvard.edu/BIC-seq/
  * This assumes per-chrom reference and prior processing

4. run_detect
  * Calls BICSeq2/NBICseq-seg_v0.7.2/NBICseq-seg.pl
  * implements GNU parallel calls

5. get_gene_level_cnv
  * runs `bedtools intersect | python gene_segment_overlap.py`
  * concatenates data

# Work at MGI

Project directory by Yige at MGI: /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/BICSEQ2.CCRCC.hg38
Snapshot of this directory taken 12/21/18: /gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/BICSEQ2.CCRCC.hg38.tar.gz
  - installed here as ./BICSEQ2.yigewu.MGI.20181221

# Description of new pipeline

Working on implementing single-sample analysis in docker container which will run in CWL.  Dockerfile is created

Setup tasks:
* need to process reference as in get_dependencies.sh
  * Yige uses /diskmnt/Datasets/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
  * per-chrom hg38 is downloaded from http://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/

https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%203/GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tbz2/download

# details of input to run_norm

* faFile is the reference sequence of this chromosome 
    * per-chrom
    * path: 
    * filename:
* MapFile is the mappability file of this chromosome 
    * Created with make_mappability step
    * needs to be generated per-chrom
* readPosFile stores all the mapping positions of all reads that uniquely mapped to this chromosome
    * I think created in get_uniq step
* binFile is the file that stores the normalized data. The data will be binned with the bin size as specified by the option -b
    * Seems that this is output

The tricky part here is that to make looping easier I need to make assumptions about filenames; that, or need
to develop some reporting mechanism where those modules which generate data share it, or else just some
centralized naming scheme.  Maybe pass around strings like "ref.chr%s.fa" which can be used in a printf statement

## Testing log 

* 12/24/18: testing make_mappability.sh on katmai: /home/mwyczalk_test/Projects/BICSEQ2/testing/direct_call
    * writes to /diskmnt/Datasets/Reference/GRCh38.d1.vd1/gem_mapping
    * increased threading count to same as what Yige used, 8 and 80
* 12/24/18: It may be better to move forward using the mapping files on katmai here:
    * /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer
    * Note that for the Manta Demo dataset, .sizes output is /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/GRCh38.d1.vd1.fa.150mer.sizes
    ```chr1  AC    248956422
       chr2  AC    242193529
       chr3  AC    198295559```
    ```
      Column 1 of above is e.g. "chr1  AC", which seems incorrect.
      This link [https://wiki.bits.vib.be/index.php/Create_a_mappability_track] does *not* include the awk step between the gem-2-wig and wigToBigWig
      steps (unlike Yige's code)
      With awk step removed, code now runs to completion on MantaDemo


