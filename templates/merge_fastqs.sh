#!/bin/bash

set -x

echo ${inDirs[0].toString().split('/')[-1]}
echo ${inDirs}

mkdir -p merged/fastq/${inName}

