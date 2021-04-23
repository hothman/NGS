#!/usr/bin/env nextflow

// path to bed file containing list of genes to extract
params.BED="../simulate_vcf/core_proper.bed"

genes = Channel.fromPath("$params.BED").splitText()  { it.replaceAll("\n", "") }


upstream_buffer = 1000000
downstream_buffer = 1000000

process noneme {
	echo true
	input: 
		val gene from genes.flatMap() 


	"""
	echo $gene
	"""

}

