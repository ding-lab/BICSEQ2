# `run_sample.C3L-chr.MGI`

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

Project configuration in `project_config.run_sample.C3L-chr.MGI.sh`

C3L-chr test dataset consists of chrom 18,19,20 from C3L-00004 CPTAC3 dataset.  It is defined
in `/BICSEQ2/testing/test_data/chromosomes.18-20.dat`


BAM Files:

Will use the following two LUAD BAMs for testing
```
C3L-00001.WGS.N.hg38    C3L-00001   LUAD    WGS blood_normal    /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/1d301dc5-ebb2-47e0-9a9f-e31ed41b4542/2595f8ca-ef17-4bf0-984d-27caaa8ee608_gdc_realn.bam   202924825766    BAM hg38    1d301dc5-ebb2-47e0-9a9f-e31ed41b4542    MGI
C3L-00001.WGS.T.hg38    C3L-00001   LUAD    WGS tumor   /gscmnt/gc2619/dinglab_cptac3/GDC_import/data/b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4/1cc7a20f-b05e-4661-95ec-399b3080a02b_gdc_realn.bam   200258660209    BAM hg38    b919a0f4-c85d-4fe0-9947-2b8cb9b9a2b4    MGI
```

Directory mapping, when launching docker:
*   data1:/gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp
    * Output directory of this project
    * gene annotation file, created in prep step, also here
*   data2:/gscmnt/gc2521/dinglab/yigewu/Projects/CPTAC3CNV/BICSEQ2/inputs
    * Mappability files 
    * Per-chrom reference in ./hg38
*   data3:/gscmnt/gc2619/dinglab_cptac3/GDC_import/data
    * common path to CPTAC3 WGS BAM files of interest

Paths are incorporated into `0_launch_docker.sh`

