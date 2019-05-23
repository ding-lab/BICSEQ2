#!/bin/bash

batchName=$1
version=$2

git add .
git commit -m ${version}
git checkout -b ${batchName}
git push origin ${batchName}
