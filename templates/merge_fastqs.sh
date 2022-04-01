#!/bin/bash
set -e
set -o pipefail
set -x

inName=${inDirs[0].toString().split('/')[-1]}
inName=\${inName%.L*}
echo \${inName}
echo ${inDirs}
ls -alh

mkdir -p merged/fastq/\${inName}
cat \${inName}*/\${inName}.1.fastq.gz > merged/fastq/\${inName}/\${inName}.1.fastq.gz
cat \${inName}*/\${inName}.2.fastq.gz > merged/fastq/\${inName}/\${inName}.2.fastq.gz
