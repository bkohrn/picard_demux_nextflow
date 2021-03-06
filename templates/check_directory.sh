#!/bin/bash
set -e
set -o pipefail
set -x
{
picard -Xmx${params.mem_amount}${params.mem_type} CheckIlluminaDirectory \\
BASECALLS_DIR=\$PWD/${params.in_dir}/Data/Intensities/BaseCalls/ \\
READ_STRUCTURE=${params.read_struct} \\
LANES=${params.num_lanes} \\
DATA_TYPES=${params.data_type} \\
TMP_DIR=./picard_temp_dir
} 2>&1 | tee -a check_illumina_directory.log

touch .checkIlluminaDirectory_good
