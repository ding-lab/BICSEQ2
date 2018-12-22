FROM ubuntu:latest

LABEL authors="Matt Wyczalkowski <m.wyczalkowski@wustl.edu>, Yige Wu <yigewu@wustl.edu>" 

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


# Makefile needs to change line
#                $(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) $(LIBCURSES) -lz -L. -lbam
# to
#                $(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) $(LIBCURSES) -lbam -lz -L.
# see here for details: https://sourceforge.net/p/samtools/mailman/message/26731547/
#
# Need to copy Samtools-0.1.7a.Makefile.patch to container
# Patching:
#   To make a patch:
#       diff -u Makefile.orig Makefile.new > Makefile.patch
#   To apply a patch (modifies .orig -> .new):
#       patch Makefile.orig Makefile.patch
# COPY samtools-0.1.7a_getUnique-0.1.3.Makefile.patch /
# also requires apt-get zlib1g-dev build-essential libncurses5-dev


RUN wget http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && tar -zxf samtools-0.1.7a_getUnique-0.1.3.tar.gz 

# We use only the misc/samtools.pl script, so no compilation required
#    && patch samtools-0.1.7a_getUnique-0.1.3/Makefile samtools-0.1.7a_getUnique-0.1.3.Makefile.patch \
#    && cd samtools-0.1.7a_getUnique-0.1.3 \
#    && make \
#    && rm /samtools-0.1.7a_getUnique-0.1.3.tar.gz


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

ENV foo=2
RUN git clone --single-branch --branch maw-dev https://github.com/mwyczalkowski/BICSEQ2.git


CMD ["/bin/bash"]
