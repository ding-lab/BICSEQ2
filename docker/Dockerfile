FROM ubuntu:latest

LABEL author="Matt Wyczalkowski" \
      maintainer="m.wyczalkowski@wustl.edu"

# libnss-sss is required for MGI installation
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libncurses5-dev \
    libnss-sss \
    python \
    python-dev \
    python-pip \
    samtools \
    vim-tiny \
    wget \
    zlib1g-dev \
    && apt-get clean


## the link to the BIC-seq2 norm and seg modules
RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz \
    && tar -xzf NBICseq-norm_v0.2.4.tar.gz \
    && wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz \
    && tar -xzf NBICseq-seg_v0.7.2.tar.gz


# Need to copy Samtools-0.1.7a.Makefile.patch to container
# Patching:
#   To make a patch:
#       diff -u Makefile.orig Makefile.new > Makefile.patch
#   To apply a patch (modifies .orig -> .new):
#       patch Makefile.orig Makefile.patch
#
COPY samtools-0.1.7a_getUnique-0.1.3.Makefile.patch /
RUN wget http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && tar -zxf samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && patch samtools-0.1.7a_getUnique-0.1.3/Makefile samtools-0.1.7a_getUnique-0.1.3.Makefile.patch \
    && cd samtools-0.1.7a_getUnique-0.1.3 \
    && make

# this succeeds

# Makefile needs to change line
#                $(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) $(LIBCURSES) -lz -L. -lbam
# to
#                $(CC) $(CFLAGS) -o $@ $(AOBJS) -lm $(LIBPATH) $(LIBCURSES) -lbam -lz -L.
# see here for details: https://sourceforge.net/p/samtools/mailman/message/26731547/

CMD ["/bin/bash"]
