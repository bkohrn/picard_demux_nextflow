#!/bin/bash

set -x

inName=${inDirs[0].toString().split('/')[-1]}
inName=\${inName%.L*}
echo \${inName}
echo ${inDirs}
ls -alh

mkdir -p merged/fastq/\${inName}
exit 1