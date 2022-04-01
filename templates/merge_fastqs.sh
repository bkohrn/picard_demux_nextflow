#!/bin/bash

set -x

inName=${inDirs[0].toString().split('/')[-1]}
echo \${inName}
echo ${inDirs}

mkdir -p merged/fastq/\${inName}

