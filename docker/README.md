Dockerfile from shiso:/Users/mwyczalk/Projects/Docker/MGI-basic

Note that docker build changed significantly in v2, and uses an apt-based
installation rather than conda-based.  This switch was motivated by a successful attempt
to compile samtools, which is not in fact necessary; details can be found in revision
history.
