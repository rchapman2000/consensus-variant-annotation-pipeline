#!/usr/bin/env/ nextflow

nextflow.enable.dsl=2

def helpMessage() {
    log.info"""
Consensus Genome Variant Annotation Pipeline

Takes an input of FASTA consenuss genomes and identifies/annotates variants found in the
genomes compared to a reference genome. The pipeline aligns each FASTA file to a reference genome using 
Minimap2 and then calls variants using freebayes. Next, the SNPs are annotated using SNPEff.

USAGE: nextflow run main.nf [options] --input INPUT_DIR --output OUTPUT_DIR --ref REFERENCE_FASTA --snpEffDB DATABASE_NAME
OPTIONS:

--input INPUT_DIR - [Required] A directory containing consensus fasta files

--output OUTPUT_DIR - [Required] A directory to place output files (If not existing, pipeline will create)

--reference REFERENCE_FASTA - [Required] A reference genome to align reads to.

--snpEffDB DATABASE_NAME - [Required] An existing SNPEff Database matching your reference sequence to annotate your variants with.


OPTIONAL:
    
    None Yet...

    """
}

// If the help parameter is supplied, link display the help message
// and quit the pipeline
params.help = false
if (params.help){
    helpMessage()
    exit 0
}

include { Setup } from './modules.nf'
include { Alignment } from "./modules.nf"
include { Variant_Calling } from "./modules.nf"
include { Variant_Annotation } from "./modules.nf"

params.input = false
params.reference = false
params.output = false
params.snpEffDB = false

// Checks the input parameter
inDir = ''
if (params.input == false) {
    // If the parameter is not set, notify the user and exit.
    println "ERROR: No input directory provided. Pipeline requires an input directory."
    exit(1)
}
else if (!(file(params.input).isDirectory())) {
    // If the input directory is not set, notify the user and exit.
    println "ERROR: ${params.input} is not an existing directory."
    exit(1)
}
else {
    // If the parameter is set, convert the value provided to a file type
    // to get the absolute path, and then convert back to a string to be
    // used in the pipeline.
    inDir = file(params.input).toString()
    println "Input Directory: ${inDir}"
}

// Create a channel for hte input files.
inputFiles_ch = Channel
    // Pull from pairs of files (illumina fastq files denoted by having R1 or R2 in
    // the file name).
    .fromPath("${inDir}/*.fasta*")
    // The .fromFilePairs() function spits out a list where the first 
    // item is the base file name, and the second is a list of the files.
    // This command creates a tuple with the base file name and two files.
    .map { it -> [it.getSimpleName(), it]}

// Checks the output parameter.
outDir = ''
if (params.output == false) {
    // If the parameter is not set, notify the user and exit.
    println "ERROR: No output directory provided. Pipeline requires an output directory."
    exit(1)
}
else {
    // If the parameter is set, convert the value provided to a file type
    // to get the absolute path, and then convert back to a string to be
    // used in the pipeline.
    outDir = file(params.output).toString()
    println(outDir)
}

// Checks the reference parameter. For this, we cannot use an
// input channel like was used for the input files. Using an input channel
// will cause Nextflow to only iterate once as the reference 
// channel would only only have 1 file in it. Thus, we manually parse
// the reference file into a tuple.
refData = ''
refName = ''
if (params.reference == false) {
    // If the parameter is not set, notify the user and exit.
    println "ERROR: no reference file proivded. Pipeline requires a reference file."
    exit(1)
}
else if (!(file(params.reference).exists())) {
    // If the reference file provided does not exist, notify the user and exit.
    println "ERROR: ${params.reference} does not exist."
    exit(1)
}
else {
    // Process the reference file to be supplied to the index step.
    
    // Parse the file provided into a file object.
    ref = file(params.reference)

    // Grab the basename of the file.
    refName = ref.getBaseName()

    // Place the file basename and file object into
    // a tuple.
    refData = tuple(refName, ref)
}

// Handles the SNPEffDB parameter.
snpEffDBVal = ''
// Checks whether the parameter was supplied.
if (params.snpEffDB == false) {
    // If not, notify the user and exit.
    println "ERROR: no SNPEff Database was provided. Pipeline requires a SNPEff Database name."
    exit(1)
}
else {
    // If so, set the database value to the value provided.
    snpEffDBVal = params.snpEffDB
}

workflow {
    Setup(refName, snpEffDBVal, outDir)

    Alignment(inputFiles_ch, refData, outDir)

    Variant_Calling(Alignment.out[0], refData, outDir)

    Variant_Annotation(Variant_Calling.out[0], snpEffDBVal, outDir)
}