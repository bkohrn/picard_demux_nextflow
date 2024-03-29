#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2


// process TEMPLATE {
//     container "${params.container__FOOBAR}"

//     input:

//     outputs:

//     scripts:
//     template: ''

// }

process check_directory {
    container "${params.container__picardtools}"
    publishDir "${params.out_prefix}/logs/", mode: "copy", overwrite: true, pattern: "check_illumina_directory.log"

    cpus params.num_processors
    memory "${params.mem_amount} ${params.mem_type}B"


    input:
    path "*"

    output:
    path ".checkIlluminaDirectory_good", emit: out_good
    path "check_illumina_directory.log", emit: out_log

    script:
    template 'check_directory.sh'

}


process make_inputs {
    container "${params.container__python}"
    publishDir "${params.out_prefix}/logs/", 
        mode: "copy", 
        overwrite: true, 
        pattern: "make_inputs.log"

    input:
    path sample_sheet
    path "*"

    output:
    path "make_inputs.log", emit: log
    path "${params.out_prefix}_eib_barcode_file.txt", emit: out_eib
    path "${params.out_prefix}_btf_multiplex_params.txt", emit: out_btf
    path "${params.out_prefix}_bts_library_params.txt", emit: out_bts
    path "${params.out_prefix}_dirsToMake.txt", emit: out_dirsToMake

    script:
    template 'make_inputs.sh'

}


process extract_barcodes {
    container "${params.container__picardtools}"

    cpus params.num_processors
    memory "${params.mem_amount} ${params.mem_type}B"


    input:
    tuple path("checkIlluminaDirectory_good"),
        path("*"),
        path(barcode_file),
        val(lane)

    output:
    tuple val(lane),
        path("${params.out_prefix}_picardExtractBarcodes/*"), 
        emit: barcodes_dir
    path "${params.out_prefix}_barcode_metrics.txt", emit: barcode_metrics

    publishDir "${params.out_prefix}/metrics", 
        mode: "copy", 
        overwrite: true, 
        pattern: "${params.out_prefix}_barcode_metrics.txt",
        saveAs: {fName -> "${params.out_prefix}.lane_${lane}.demux_${workflow.start}.barcode_metrics.txt"}

    script:
    template 'extract_barcodes.sh'

}


process basecalls_to_fastq {
    container "${params.container__picardtools}"
    publishDir "${params.out_prefix}", 
        mode: "copy", 
        overwrite: true, 
        enabled: params.save_individual_lanes,
        pattern: "fastq/*"
    
    cpus params.num_processors
    memory "${params.mem_amount} ${params.mem_type}B"

    input:
    tuple path("checkIlluminaDirectory_good"),
        path("*"),
        path(multiplex_params),
        val(lane),
        path("Barcodes_dir/*"),
        path(dirs_to_make)
    
    output:
    path "fastq/*", emit:out_fastqs

    script:
    template 'basecalls_to_fastq.sh'
}

process basecalls_to_sam {
    container "${params.container__picardtools}"
    publishDir "${params.out_prefix}", 
        mode: "copy", 
        overwrite: true, 
        enabled: params.save_individual_lanes,
        pattern: "sam/*"
    
    cpus params.num_processors
    memory "${params.mem_amount} ${params.mem_type}B"


    input:
        tuple path("checkIlluminaDirectory_good"),
        path("*"),
        path(library_params),
        val(lane),
        path("Barcodes_dir/*"),
        path(dirs_to_make)

    output:
    path "sam/*", emit: out_sams

    script:
    template 'basecalls_to_sam.sh'
}

process merge_fastqs {
    container "${params.container__base}"
    publishDir "${params.out_prefix}/", 
        mode: "copy", 
        overwrite: true, 
        pattern: "merged/fastq/*"

    input:
    path(inDirs)

    
    output:
    path "merged/fastq/*", emit:out_fastqs

    script:
    template 'merge_fastqs.sh'

}

process merge_sams {
    container "${params.container__samtools}"
    publishDir "${params.out_prefix}/", 
        mode: "copy", 
        overwrite: true, 
        pattern: "merged/sam/*"

    input:
    path(inDirs)

    
    output:
    path "merged/sam/*", emit:out_sams

    script:
    template 'merge_sams.sh'

}