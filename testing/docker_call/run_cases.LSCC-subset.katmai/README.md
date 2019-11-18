# Run WGS somatic CNV on katmai
This is the root folder where we configure and launch the pipeline.
Each project should have its own root folder.


## Configure scripts and config files

- `project_config.sh` controls the paths seen inside the Docker instance.
- `project_config-host.sh` controls the paths on the host machine.

Create a folder `dat` under this folder to store all the metadata:

    mkdir dat


## Edit `project_config-host.sh`
Change to the paths where annotations live (`DATA2` and `DATA3`).


## Edit `project_config.sh`
Here controls what the Docker instance will read. Usually we don't need to
modify this. Double check the filename of `GENE_BED`.


## 1. Generate the list of case IDs to process
First, run `1_make_case_names.sh` to create a list of case IDs which we will
process. Otherwise, supply the case IDs at `dat/case_names.dat`.

    bash 1_make_case_names.sh


## 2. Make Dockermap file
Dockermap file which provides mapping from host to container paths.

    bash 2_make_dockermap.sh


## 3. Make CaseList file
CaseList file contains BAM paths (mapped to container) and other details to
process a given case.  Reads in BamMap and a list of case names.

    bash 3_make_case_list.sh



# Testing
Good idea to test everything prior to run. Can do `dry run` to print out
commands rather than executing them. The dry run argument -d can be repeated
to get down to scripts which are called. the -1 argument will exit after one
case is processed:
```
bash A.process_project_cases.sh -d1 - < dat/case_names.dat
```

Adding more `d`s to test run at a deeper level (say, `-ddd1`) and ensure the
commands print out successfully, for example,
```
bash A.process_project_cases.sh -ddd1 - < dat/case_names.dat
```

The output will be at `OUTD_H="$OUTBASE_H/$PROJECT"` (see `project_config-host.sh`).



# Running
To launch all cases with 2 running at once:
```
bash A.process_project_cases.sh -J 2 - < dat/case_names.dat
```

Run a specific step `<step>` of a case `<case>` by:
```
bash A.process_project_cases.sh <Case ID> -s <step>
```

Alternatively, use `B` to find cases to run
```
bash B.evaluate_project_cases.sh -f not_started -u | bash A.process_project_cases.sh -
```

