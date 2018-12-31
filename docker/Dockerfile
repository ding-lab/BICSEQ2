FROM ubuntu:latest

LABEL authors="Matt Wyczalkowski <m.wyczalkowski@wustl.edu>, Yige Wu <yigewu@wustl.edu>" 

# Using apt-based installation rather than conda, but conda would work
# libnss-sss is required for MGI installation
RUN apt-get update && apt-get install -y \
    git \
    libnss-sss \
    parallel \
    python \
    python-dev \
    python-pip \
    samtools \
    vim-tiny \
    wget \
    && apt-get clean

## the link to the BIC-seq2 norm and seg modules
RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz \
    && tar -xzf NBICseq-norm_v0.2.4.tar.gz \
    && wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz \
    && tar -xzf NBICseq-seg_v0.7.2.tar.gz \
    && rm NBICseq-norm_v0.2.4.tar.gz NBICseq-seg_v0.7.2.tar.gz


# We use only the misc/samtools.pl script, so the following target need not be compiled.
RUN wget http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && tar -zxf samtools-0.1.7a_getUnique-0.1.3.tar.gz 


# Install GEM library 
RUN wget https://sourceforge.net/projects/gemlibrary/files/gem-library/Binary%20pre-release%203/GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tbz2 \
    && bzip2 -d GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tbz2 \
    && tar -xf GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tar \
    && mv GEM-binaries-Linux-x86_64-core_i3-20130406-045632/bin/* /usr/local/bin \
    && cd / \
    && rm -rf GEM-binaries-Linux-x86_64-core_i3-20130406-045632 GEM-binaries-Linux-x86_64-core_i3-20130406-045632.tar

# install wig tools 
RUN cd /usr/local/bin \
    && wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigToBedGraph \
    && wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig \
    && chmod 555 bigWigToBedGraph wigToBigWig

# Increment foo to force `git clone`
ENV foo=4 
RUN git clone --single-branch --branch maw-dev https://github.com/mwyczalkowski/BICSEQ2.git


CMD ["/bin/bash"]
