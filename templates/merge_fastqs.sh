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
dirList=(\$(ls -d \${inName}*))
dir1=\${dirList[0]}
for fIter in \$(ls \${dir1}/\${inName}.*.fastq.gz); do
    fileName=\$(basename \${fIter})
    cat \${inName}*/\${fileName} > merged/fastq/\${inName}/\${fileName}
done
