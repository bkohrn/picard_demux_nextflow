#!/bin/bash

set -x

echo ${inDir[0].toString().split('/')[-1]}
echo ${inDir}

mkdir -p merged/fastq/${inName}

