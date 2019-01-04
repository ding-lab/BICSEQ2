# on shiso:
bash 0_start_docker.sh ~/Data

# On Katmai:

## Reference

*host*: /diskmnt/Datasets/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
Note that above reference directory does not have per-chrom data.  **TODO** Look these up, allow different paths, see if all-chrom reference will work in normalization step

Root directory of per-chrom reference.  `/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/hg38` Filename is e.g. chr20.fa

## Data

### Preliminary testing
C3L-00004 Chr 20 test dataset can be found here:
* `/diskmnt/Datasets/BICSEQ2-dev.tmp`
    * `chr20.fa` - per chrom reference
    * `GRCh38.d1.vd1.fa.150mer.chr20.txt` - mappability file
    * `C3L-00004_tumor_chr20.seq` - sequence file
    * norm_config files:
        * C3L-00004_tumor_config.txt - host paths
        * C3L-00004_tumor_config-remapped.txt - container paths, with /diskmnt/Datasets/BICSEQ2-dev.tmp:/data

### Whole-step testing
Will use reference and mapping data as they exist on katmai.

Reference and mapping data here: `/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs/hg38`

# Testing of normalization and segmentation steps:
For testing of normalization on katmai, using data in 
*   data1:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  (chrom reference (./hg38) and mappability)
*   data2:/diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq  (.seq files)
*   data3:/diskmnt/Datasets/BICSEQ2-dev.tmp (output)
*   data4:/diskmnt/Datasets/Reference/GRCh38.d1.vd1 (all-chrom reference, unused)

Details are in `project_config.test_norm.katmai.sh`
Start container with,
```
bash 0_start_docker.sh  /diskmnt/Projects/CPTAC3CNV/BICSEQ2/inputs  \
    /diskmnt/Projects/CPTAC3CNV/BICSEQ2/outputs/UCEC.hg38.test/run_uniq  \
    /diskmnt/Datasets/BICSEQ2-dev.tmp \
    /diskmnt/Datasets/Reference/GRCh38.d1.vd1
```

# MGI, 
bash 0_start_docker.sh -M /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp
