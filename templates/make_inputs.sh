#!/bin/bash
set -e
set -o pipefail
set -x
{
make_picard_demux_files.py \\
    -i "${sample_sheet}" \\
    -o "${params.out_prefix}" \\
    -r "${params.read_struct}" \\
    --ignore_unknown "${params.ignore_unexpected_barcodes}"
} 2>&1 | tee -a make_inputs.log
