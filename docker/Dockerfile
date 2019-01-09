FROM ubuntu:latest

LABEL authors="Matt Wyczalkowski <m.wyczalkowski@wustl.edu>, Yige Wu <yigewu@wustl.edu>" 

# Using apt-based installation rather than conda, but conda would work
# libnss-sss is required for MGI installation
# bedtools needed for prep_gene_annotation.sh
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    bedtools \  
    git \
    libnss-sss \
    parallel \
    python \
    python-dev \
    python-pip \
    r-base \
    samtools \
    vim-tiny \
    wget \
    && apt-get clean

# Install bedops.  Needed for prep_gene_annotation.sh
RUN git clone https://github.com/bedops/bedops.git \
    && cd bedops \
    && make \
    && make install

# Possibly need to add the following:
# PATH="$PATH:/bedops/bin/"

## the link to the BIC-seq2 norm and seg modules
## Note that chmod / chown required for MGI installations, where otherwise executables may not be visible
RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz \
    && tar -xzf NBICseq-norm_v0.2.4.tar.gz \
    && chown -R root:root /NBICseq-norm_v0.2.4 \
    && cd /NBICseq-norm_v0.2.4 \
    && chmod 755 NBICseq-norm.pl BRS_1bp BRS_1bp randomSample DataPrepare \
    && chmod 644 R/*.R \
    && rm /NBICseq-norm_v0.2.4.tar.gz

RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz \
    && tar -xzf NBICseq-seg_v0.7.2.tar.gz \
    && chown -R root:root /NBICseq-seg_v0.7.2 \
    && cd /NBICseq-seg_v0.7.2 \
    && chmod 755 . combineFile MBIC-seq_v0.1.5 R bootstrap \
    && chmod 644 *.pl R/*.R \
    && chmod 755 MBIC-seq_v0.1.5/MBICseq combineFile/combineFile BICseqTwoSample.pl bootstrap/bootstrapTest \
    && rm /NBICseq-seg_v0.7.2.tar.gz

# We use only the misc/samtools.pl script, so the following target need not be compiled.
RUN wget http://compbio.med.harvard.edu/BIC-seq/BICseq2/samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && tar -zxf samtools-0.1.7a_getUnique-0.1.3.tar.gz \
    && chown -R root:root /samtools-0.1.7a_getUnique-0.1.3 \
    && chmod 755 /samtools-0.1.7a_getUnique-0.1.3 /samtools-0.1.7a_getUnique-0.1.3/misc /samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl \
    && rm /samtools-0.1.7a_getUnique-0.1.3.tar.gz

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

RUN pip install numpy

# Will run `python -S` to not import site data on initialization.  This is important in MGI
ENV PYTHONPATH="/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/dist-packages"

#USER bps
#COPY vimrc /home/bps/.vimrc
#ENV HOME=/home/bps

ENV LANG=C

# set up working directory
COPY . /BICSEQ2
WORKDIR /BICSEQ2

CMD ["/bin/bash"]
