FROM debian:latest

#  $ docker build . -t continuumio/miniconda3:latest -t continuumio/miniconda3:4.5.11
#  $ docker run --rm -it continuumio/miniconda3:latest /bin/bash
#  $ docker push continuumio/miniconda3:latest
#  $ docker push continuumio/miniconda3:4.5.11

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git tar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN yes | conda install -c conda-forge parallel
RUN yes | conda install -c r r
RUN yes | conda install -c conda-forge ncurses
RUN yes | conda install -c bioconda samtools

## download  BICseq2-norm and compile it
RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-norm_v0.2.4.tar.gz -O /opt/NBICseq-norm_v0.2.4.tar.gz
WORKDIR "/opt"
RUN tar -xzf NBICseq-norm_v0.2.4.tar.gz
WORKDIR "/opt/NBICseq-norm_v0.2.4"
RUN make clean
RUN make

RUN wget http://compbio.med.harvard.edu/BIC-seq/NBICseq-seg_v0.7.2.tar.gz  -O /opt/NBICseq-seg_v0.7.2.tar.gz
WORKDIR "/opt"
RUN tar -xzf NBICseq-seg_v0.7.2.tar.gz
WORKDIR "/opt/NBICseq-seg_v0.7.2"
RUN make clean
RUN make
RUN chmod -R 777 /opt/NBICseq-norm_v0.2.4 /opt/NBICseq-seg_v0.7.2

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
