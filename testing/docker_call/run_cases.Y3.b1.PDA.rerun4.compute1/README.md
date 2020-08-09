Develop and test running of multiple cases on compute1

# Download dependencies

Make sure the reference .fa files by chromosome and mappability files are at /data1 indicated in the project_config-host.sh

# Configure scripts and config files

## 1. Edit `project_config-host.sh`

First, create list of cases which we will process.  



## 2. Make Dockermap file
Dockermap file which provides mapping from host to container paths.  

## 3. Make CaseList file 
CaseList file contains BAM paths (mapped to container) and other details to process a given case.  
Reads in BamMap and a list of case names.


# Testing

Good idea to test everything prior to run.  Can do `dry run` to print out commands rather than executing them.  The
dry run argument -d can be repeated to get down to scripts which are called.  the -1 argument will exit after one
case is processed.

```
bash A.process_project_cases.sh -d1 - < dat/case_names.dat
```
# Launching the docker container to submit jobs
```
bash /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/BATCH.Y3.b1/scripts/WUDocker/start_docker.sh -I mwyczalkowski/bicseq2 -M compute1 /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/WGS_CNV_Somatic/ /home/yigewu/ /storage1/fs1/m.wyczalkowski/Active/Primary/Resources/References/ /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/GDC_import/data/
```

# Running

To launch all cases with 3 running at once:
```
bash A.process_project_cases.sh -J 3 -  < dat/case_names.dat
```

Alternatively, use `B` to find cases to run
```
bash B.evaluate_project_cases.sh -f not_started -u | bash A.process_project_cases.sh -
```

To generate analysis description file: https://docs.google.com/document/d/1Ho5cygpxd8sB_45nJ90d15DcdaGCiDqF0_jzIcc-9B4/edit
```
bash C.make_analysis_description.sh
```

# Trouble shooting
## Unusual whole chromosome deletion of chr1 or other whole-chromosome abberation
### Potential cause: insufficient memory for running jobs
#### How to check
Check the distribution of 3rd column of the .norm.bin file for the unusual chromosome for the norm directory under your output directory.
For example, in a previous issue for CPTAC3 PDA cohort, we checked the later half of the intermediate file for chr1 of the tumor reads of the problematic samples by
```
tail -1000000 C3L-03129/norm/C3L-03129.WGS.T.hg38.chr1.norm.bin | cut -f 3| sort | uniq -c | sort -nr | less
```
The second column of the result shows the observing values and the first column shows the number of occurrence. We saw a overwhelming 0s in the result, indicating it’s possible that because chr1 is the longest chromosome, the memory is insufficient to process the later half of the chromosome
#### Solution: increase the memory parameter G (in GB) at A.process_project_cases.sh 
