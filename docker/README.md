Dockerfile from shiso:/Users/mwyczalk/Projects/Docker/MGI-basic

samtools does not compile, which is not generally a problem since only the .pl script
is used. We made a successful effort to compile it and generated patches to the distributed
Makefile to make it work: `samtools-0.1.7a_getUnique-0.1.3.Makefile.patch`

