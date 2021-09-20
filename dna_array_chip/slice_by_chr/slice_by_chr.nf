#!/usr/bin/env nextflow

// vcf file to be sliced 
params.vcf = "/path/tovcf/northafrica_syria_filtered.vcf.gz"
// outputfolder
params.outfolder="./sliced_vcfs/"
// prefix for naming tghe output vcf file
params.prefix="Comas2017"



chrID = Channel.from( [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22] )

process sliceChom {
	tag "$id"
	input: 
		val id from chrID
	output: 
		file("*chr*.vcf.gz")
	publishDir params.outfolder, mode:'copy'

	"""
	bcftools view -r $id ${params.vcf} -O z -o ${params.prefix}_chr${id}.vcf.gz
	"""

}