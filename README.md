# Processing description
we used BIC-seq2 (Xi et al., 2016), a read-depth-based CNV calling algorithm to detect copy number variation (CNVs) from the bisulfite WGBS data of the mouse clones. Briefly, BIC-seq2 divides genomic regions into disjoint bins and counts uniquely aligned reads in each bin. Then, it combines neighboring bins into genomic segments with similar copy numbers iteratively based on Bayesian Information Criteria (BIC), a statistical criterion measuring both the fitness and complexity of a statistical model. 
We used paired-sample CNV calling that takes a pair of samples as input and detects genomic regions with different copy numbers between the two samples. We used a bin size of ∼100 bp and a lambda of 3 (a smoothing parameter for CNV segmentation). We recommend to call segments as copy gain or loss when their log2 copy ratios were larger than 0.2 or smaller than −0.2, respectively (according to the BIC-seq publication).

## Processing pipeline
https://github.com/ding-lab/BICSEQ2

Contact: yigewu@wustl.edu
