Develop and test running of multiple cases on MGI

Goal here is to process 3 CCRCC cases to compare against Yige's analysis.
Case C3L-00796 apparently has problems: "tumor samples for this one cannot generate .seq file for chrX"

## 1. make list of case names
First, create list of cases which we will process.  

## 2. Make Dockermap file
Dockermap file which provides mapping from host to container paths.  

## 3. Make CaseList file 
CaseList file contains BAM paths (mapped to container) and other details to process a given case.  
Reads in BamMap and a list of case names.


# Testing

Launched first 5 cases 1/12/19 with,
    head -n 5 dat/case_names.dat | bash A.process_project_cases.sh -

Follow first one along here:
    /gscmnt/gc2508/dinglab/mwyczalk/BICSEQ2-dev.tmp/run_cases.LUAD.MGI/11LU013/bsub/1547328929.err


# Running

```
bash B.evaluate_project_cases.sh -f not_started -u | bash A.process_project_cases.sh -
```

