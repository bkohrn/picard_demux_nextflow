#!/usr/bin/env python3

import argparse
import re
from argparse import ArgumentParser

def main():
    # read parameters
    parser = ArgumentParser()
    parser.add_argument('-i','--input_file',
        dest='input',
        action="store",
        type=str,
        help="Input sample sheet",
        required=True)
    parser.add_argument(
        '-o','--out_prefix',
        dest='prefix',
        action="store",
        type=str,
        help="A prefix for output files",
        required=True)
    parser.add_argument(
        '-r',"--read_structure",
        dest="read_structure",
        action="store",
        type=str,
        help="Read structure expected",
        default="151T10B10B151T"
    )
    parser.add_argument(
        "--ignore_unknown",
        dest="unknown",
        action="store",
        type=str,
        help="true/false on whether to ignore unknown reads",
        choices=["true","false"], 
        default="false"
    )
    o = parser.parse_args()
    # make barcode file for picard ExtractIlluminaBarcodes
    # open output files
    # Open ExtractIlluminaBarcodes file
    out_eib = open(f"{o.prefix}_eib_barcode_file.txt", 'w')
    # Header for ExtractIlluminaBarcodes input
    ## library_name\tbarcode_name\tbarcode_sequence_1\tbarcode_sequence_2\n
    out_eib.write("library_name\tbarcode_name\tbarcode_sequence_1\tbarcode_sequence_2\n")
    # Open IlluminaBasecallsToFastq file
    out_btf = open(f"{o.prefix}_btf_multiplex_params.txt", 'w')
    # Header for IlluminaBasecallsToFastq
    ## OUTPUT_PREFIX\tlibrary_name\tbarcode_name\tBARCODE_1\tBARCODE_2\n
    out_btf.write("OUTPUT_PREFIX\tlibrary_name\tbarcode_name\tBARCODE_1\tBARCODE_2\n")
    # write unknown line
    if not o.unknown:
        out_btf.write(f"fastq/UNKNOWN_INDEX/UNKNOWN_INDEX\t"
                    f"UNKN\tUNKN\t"
                    f"N\tN\n")
    # Open IlluminaBasecallsToSam file
    out_bts = open(f"{o.prefix}_bts_library_params.txt", 'w')
        # write unknown line
    if not o.unknown:
        out_bts.write(f"sam/UNKNOWN_INDEX/UNKNOWN_INDEX_unmapped.bam\t"
                    f"UNKN\tUNKN\t"
                    f"N\tN\n")

    # Header for IlluminaBasecallsToSam
    ## OUTPUT\tSAMPLE_ALIAS\tLIBRARY_NAME\tBARCODE_1\tBARCODE_2\n
    out_bts.write("OUTPUT\tSAMPLE_ALIAS\tLIBRARY_NAME\tBARCODE_1\tBARCODE_2\n")
    out_filesToMake = open(f"{o.prefix}_dirsToMake.txt", 'w')
    if not o.unknown:
        out_filesToMake.write(
                f"sam/UNKNOWN_INDEX/\n"
                f"fastq/UNKNOWN_INDEX/\n")
    # Open sample sheet
    in_sample_sheet = open(o.input, 'r')
    line = next(in_sample_sheet).strip().strip(',')
    sample_IDs = []

    # set up to check index size

    while line != "[Data]":
        line = next(in_sample_sheet).strip().strip(',')
    header_line = next(in_sample_sheet).strip().strip(',').split(',')
    for line in in_sample_sheet:
        line_dict = dict(zip(header_line, line.strip().rstrip(',').split(',')))
        samp_name = re.sub(r'[^\w\d\-_\.]','_',line_dict['Sample_Name'])
        if samp_name in sample_IDs:
            raise Exception("ERROR: Duplicate sample names.  Check your 'Sample_Name' column.")
        sample_IDs.append(samp_name)
        out_eib.write(f"{samp_name}\t"
                      f"{line_dict['I7_Index_ID']}\t"
                      f"{line_dict['index']}\t"
                      f"{line_dict['index2']}\n")
        out_btf.write(f"fastq/{samp_name}/{samp_name}\t"
                      f"{samp_name}\t"
                      f"{line_dict['I7_Index_ID']}\t"
                      f"{line_dict['index']}\t"
                      f"{line_dict['index2']}\n")
        out_bts.write(f"sam/{samp_name}/{samp_name}_unmapped.bam\t"
                      f"{samp_name}\t"
                      f"{line_dict['I7_Index_ID']}\t"
                      f"{line_dict['index']}\t"
                      f"{line_dict['index2']}\n")
        out_filesToMake.write(
            f"sam/{samp_name}/\n"
            f"fastq/{samp_name}/\n")
    in_sample_sheet.close()
    out_eib.close()
    out_btf.close()
    out_bts.close()
    out_filesToMake.close()

if __name__ == "__main__":
    main()
