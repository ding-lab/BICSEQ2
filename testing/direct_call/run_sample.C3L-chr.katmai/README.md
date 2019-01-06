# `run_sample.C3L-chr.katmai`

Test the following sample workflow steps on C3L-chr dataset:
* Preparation
    * Create gene annotation file
        * implemented in `a_prep_gene_annotation`
        * this is typically only done only once per system installation
        * Requires download of GFF file from ensembl
        * Is relatively fast
* Per-sample
    * Unique Reads
    * Normalization
    * Segmentation
    * Gene annotation

Performance
* get_unique ~ 17 min for chrom 18,19,20
  * because of this, implementing option in project config to use either pipeline or preprocessed
    .seq files
  * /data4 is mapped to preprocessed .seq data

Starting now, doing `get_unique` step.  Previously, used `.seq` files provided by other runs.

Project configuration in `project_config.run_sample.C3L-chr.katmai.sh`

C3L-chr test dataset consists of chrom 18,19,20 from C3L-00004 CPTAC3 dataset.  It is defined
in `/BICSEQ2/testing/test_data/chromosomes.18-20.dat`

Reference and mapping data on katmai at `/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/hg38`

Directory mapping, when launching docker:
*   data1:/diskmnt/Datasets/BICSEQ2-dev.tmp 
    * Output directory of this project
    * gene annotation file, created in prep step, also here
*   data2:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  
    * Mappability files 
    * Per-chrom reference in ./hg38
*   data3:/diskmnt/Projects/cptac_downloads_3/GDC_import/data 
    * common path to CPTAC3 WGS BAM files of interest

Paths are incorporated into `0_launch_docker.sh`

