Develop and test running of multiple cases on MGI

## 1. make list of case names
First, create list of cases which we will process.  For instance, LUAD WGS hg38 cases:
```
grep LUAD ~/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat | grep WGS | grep hg38 | cut -f 2 | sort -u | head > dat/case_names.dat
```

## 2. Make Dockermap file
Dockermap file which provides mapping from host to container paths.  

## 3. Make CaseList file 
CaseList file contains BAM paths (mapped to container) and other details to process a given case.  
Reads in BamMap and a list of case names.


