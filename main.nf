#!/usr/bin/env nextflow 

/*
################################################################################
Nextflow Definitions
################################################################################
*/

nextflow.enable.dsl=2
version = '0.0.1'

/*
################################################################################
Accessory functions to include
################################################################################
*/

include {callHelp; checkAndSetArgs; printArguments} from './lib/utilities.nf'

/*
################################################################################
Checking and printing input arguments
################################################################################
*/

callHelp(params, version)                 // Print help & version
checked_arg_map = checkAndSetArgs(params) // Check args for conflics
printArguments(checked_arg_map)           // Print pretty args to terminal

/*
################################################################################
Implicit workflow: Run the RNA-seq sub-workflow
################################################################################
*/

// Workflows
include { QC } from './workflows/qc' params(checked_arg_map)
include { BCL2FASTQ } from './workflows/bcl2fastq' params(checked_arg_map)
include { RNASEQ } from './workflows/rnaseq' params(checked_arg_map)
//   include { DEMULTIPLEX } from './workflows/demultiplex' params(checked_arg_map)

workflow {

  if(checked_arg_map.path_bcl) {
    BCL2FASTQ()
    BCL2FASTQ.out.bcl2fq_reads.set { reads }
    BCL2FASTQ.out.bcl2fq_stats.set { stats }

  } else {
    Channel.empty().set { reads } // Only needed if BCL2FASTQ not being used
    Channel.of(false).set { stats } // Needed if BCL2FASTQ not run
  }
  
  QC(reads)
  RNASEQ(reads)
}
