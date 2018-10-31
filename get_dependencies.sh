#!/bin/bash

inputDir=$1
bamMapGit=$2
mappabilityLink=$3
bicseq2normLink=$4
bicseq2segLink=$5

cd ${inputDir}

git clone --recursive ${bamMapGit}

wget ${mappabilityLink}
tar -xzf hg19.CRG.100bp.tar.gz

wget ${bicseq2normLink}
tar -xzf NBICseq-norm_v0.2.4.tar.gz

wget ${bicseq2segLink}
tar -xzf NBICseq-seg_v0.7.2.tar.gz

cp -r /diskmnt/Projects/Users/qgao/Tools/BICSeq2/samtools-0.1.7a_getUnique-0.1.3 .
