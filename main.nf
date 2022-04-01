#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// Set default parameters
params.in_dir = false  // User can provide their own in_dir with --in_dir WHATEVER_VALUE at runtime
params.out_prefix = false
params.read_struct = false
params.data_type = false
params.machine_name = false
params.flowcell_barcode = false
params.run_barcode = false
params.lane = false
params.num_lanes = 1
params.num_processors = 1
params.compress_outputs = "true"
params.ignore_unexpected_barcodes = "true"
params.seq_center = false
params.mem_amount = 8
params.mem_type = "G"
params.makeFastq = false
params.makeSam = false

// Set the containers to use for each component
params.container__base = "quay.io/biocontainers/snakemake:6.10.0--hdfd78af_0"
params.container__python = "quay.io/fhcrc-microbiome/python-pandas:0fd1e29"
params.container__picardtools = "quay.io/biocontainers/picard:2.20.8--0"

// Import the processes defined in modules/processes.nf into the main workflow scope
include {
    check_directory;
    make_inputs;
    extract_barcodes;
    basecalls_to_fastq;
    basecalls_to_sam;
    merge_fastqs
} from './modules/processes'

// Function which prints help message text
def helpMessage() {
    log.info"""
Usage:
nextflow run <REPO_URL> <ARGUMENTS>
Required Arguments:
  
  Input Data:
  ADD HELP TEXT HERE
    """.stripIndent()
}

log.info"""This pipeline started""".stripIndent()
// Main workflow
workflow {
    log.info"""This pipeline started""".stripIndent()
    // Check to make sure that all of the required inputs have been provided
    if ( params.in_dir == false || params.out_prefix == false || params.read_struct == false || params.data_type == false || params.machine_name == false || params.flowcell_barcode == false ){
        // Print the help message
        helpMessage()

        // Exit out
        exit 1
    }
    log.info"""Inputs look good""".stripIndent()
    // Primary input for all processes
    Channel
        .fromPath("${params.in_dir}")
        .set{
            basecalls_dir
        }
    log.info"""Set up data channel""".stripIndent()
    // Run the check_directory process, using all of the files from the basecalls folder
    check_directory (
        basecalls_dir
    )
    log.info"""directory checked""".stripIndent()
    // Make the inputs
    make_inputs (
        // Sample sheet
        Channel
            .fromPath("${params.in_dir}/SampleSheet.csv"),
        // Also wait for the check_directory process to finish (successfully)
        check_directory.out.out_good
    )
    println"${params.lane}"
    // Setup lanes channel
    lanesToRun = Channel
        .from(params.lane)
        .splitCsv()
        .flatten()
    lanesToRun.view()
    
    // Extract the barcodes
    extract_barcodes(
        // Also wait for the check_directory process to finish (successfully)
        check_directory
            .out
            .out_good
            .combine(basecalls_dir)
            .combine(make_inputs.out.out_eib)
            .combine(lanesToRun)
    )
    if (params.makeFastq ) {
        // convert to fastq
        basecalls_to_fastq(
            // Also wait for the check_directory process to finish (successfully)
            check_directory.out
                .out_good
                .combine(basecalls_dir)
                .combine(make_inputs.out.out_btf)
                .combine(extract_barcodes.out.barcodes_dir)
                .combine(make_inputs.out.out_dirsToMake)
        )

        dirPairsFastq = basecalls_to_fastq.out.out_fastqs
            .toList()
            .transpose()
            .view()
        
        dirNamesFastq = dirPairsFastq.map {
            it -> [
                it[0].toString().split('/')[-1],
                it
            ]
        }
        merge_fastqs(
            dirPairsFastq
        )
    }

    if (params.makeSam) {
        // convert to sam
        basecalls_to_sam(
                check_directory
                .out
                .out_good
                .combine(basecalls_dir)
                .combine(make_inputs.out.out_bts)
                .combine(extract_barcodes.out.barcodes_dir)
                .combine(make_inputs.out.out_dirsToMake)
        )
    // dirPairs = basecalls_to_fastq.out.out_fastqs.toList().transpose().view()
        
    //     dirNames = dirPairs.map {
    //         it -> it[0].toString().split('/')[-1]
    //     }
    //     merge_bams(
    //         dirNames,
    //         dirPairs
    //     )
    }

}