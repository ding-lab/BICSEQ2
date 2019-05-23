# BIC-Seq2

BICSEQ2 pipeline, version 2.0

## Processing description
We used BIC-seq2 (Xi et al., 2016), a read-depth-based CNV calling algorithm to
detect somatic copy number variation (CNVs) from the WGS data of tumors.
Briefly, BIC-seq2 divides genomic regions into disjoint bins and counts
uniquely aligned reads in each bin. Then, it combines neighboring bins into
genomic segments with similar copy numbers iteratively based on Bayesian
Information Criteria (BIC), a statistical criterion measuring both the fitness
and complexity of a statistical model. 

We used paired-sample CNV calling that takes a pair of samples as input and
detects genomic regions with different copy numbers between the two samples. We
used a bin size of ∼100 bp and a lambda of 3 (a smoothing parameter for CNV
segmentation). We recommend to call segments as copy gain or loss when their
log2 copy ratios were larger than 0.2 or smaller than −0.2, respectively
(according to the BIC-seq publication).

## Processing pipeline
This is a docker implementation.
Github: https://github.com/mwyczalkowski/BICSEQ2.git

## Input data

WGS tumor and normal 

## Output

* CNV file.  Output of Segmentation step.  Per-segment log2(copy ratio)
* SEG file.  Per-gene log2(copy ratio)

# Contact: 

* Yige Wu <yigewu@wustl.edu>
* Matt Wyczalkowski <m.wyczalkowski@wustl.edu>

