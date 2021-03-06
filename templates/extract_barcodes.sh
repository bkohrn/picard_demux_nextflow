#!/bin/bash
set -e
set -o pipefail
set -x

{
OUTDIR="${params.out_prefix}_picardExtractBarcodes"
mkdir \$OUTDIR

echo \$(picard ExtractIlluminaBarcodes --version)

echo ${lane}

picard -Xmx${params.mem_amount}${params.mem_type} \\
    ExtractIlluminaBarcodes \\
    BASECALLS_DIR=\$PWD/${params.in_dir}/Data/Intensities/BaseCalls/ \\
    BARCODE_FILE=${barcode_file} \\
    READ_STRUCTURE=${params.read_struct} \\
    LANE=${lane} \\
    OUTPUT_DIR=\$OUTDIR  \\
    METRICS_FILE=${params.out_prefix}_barcode_metrics.txt \\
    NUM_PROCESSORS=${task.cpus} \\
    TMP_DIR=./picard_temp_dir
} 2>&1 | tee -a extract_barcodes.log
