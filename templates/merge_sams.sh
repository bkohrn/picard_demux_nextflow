#!/bin/bash
set -e
set -o pipefail
set -x

inName=${inDirs[0].toString().split('/')[-1]}
inName=\${inName%.L*}
echo \${inName}
echo ${inDirs}
ls -alh

mkdir -p merged/sam/\${inName}
samtools merge -o merged/sam/\${inName}/\${inName}_unmapped.bam \${inName}*/\${inName}_unmapped.bam 
