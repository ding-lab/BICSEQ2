# BIC-Seq2
## Processing description
we used BIC-seq2 (Xi et al., 2016), a read-depth-based CNV calling algorithm to detect somatic copy number variation (CNVs) from the WGS data of tumors. Briefly, BIC-seq2 divides genomic regions into disjoint bins and counts uniquely aligned reads in each bin. Then, it combines neighboring bins into genomic segments with similar copy numbers iteratively based on Bayesian Information Criteria (BIC), a statistical criterion measuring both the fitness and complexity of a statistical model. 

We used paired-sample CNV calling that takes a pair of samples as input and detects genomic regions with different copy numbers between the two samples. We used a bin size of ∼100 bp and a lambda of 3 (a smoothing parameter for CNV segmentation). We recommend to call segments as copy gain or loss when their log2 copy ratios were larger than 0.2 or smaller than −0.2, respectively (according to the BIC-seq publication).

## Processing pipeline
Github: https://github.com/ding-lab/BICSEQ2

## Processing Steps:
1. Get the uniquely mapped reads from the case and the control  genome bam files, respectively
	a. inputs: WGS BAMs
	b. outputs: .seq files
	c. script: run_uniq_bsub.sh (MGI) or run_uniq.sh (Katmai) 
2. Normalize the case and control genome individually using BICseq2-norm
	a. inputs: .seq files
	b. outputs: .bin files
	c. script: run_norm_bsub.sh (MGI) or run_norm.sh (Katmai)
3. Detect CNV in the case genome based on the normalized data of the case genome and the conrol genome. 
	a. inputs: .bin files
	b. outputs: .CNV files
	c. script: run_detect.sh (Katmai)

## Pipeline Implementation at Katmai or local:
1. install conda
2. install conda environment using ./dependencies/install_conda_env.sh
3. examine and edit the variables contained within the script named main.sh.
4. activate conda environment: source activate bicseq2
5. make sure all the dependencies mentioned in get_dependencies.sh are in ../inputs
6. get command lines of each step: bash main.sh
6. run the command lines of each step subsequently, check the log files and outputs generated

## Pipeline Implementation using bsub:
1. examine and edit the variables contained within the script named main_bsub.sh
2. make sure all the dependencies mentioned in get_dependencies.sh are in ../inputs
3. bash main_bsub.sh {stepName}. For example, bash main_bsub.sh run_norm.
4. bash {stepName}_bsub.sh. For example, bash run_norm_bsub.sh

Contact: yigewu@wustl.edu
