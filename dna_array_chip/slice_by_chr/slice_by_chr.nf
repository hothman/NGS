#!/usr/bin/env nextflow

// vcf file to be sliced 
params.vcf = "/media/houcem/theDrum/BILIM/adme_chip_data/sliced_vcfs/Affy6_ADME_African.vcf.gz"
// outputfolder
params.outfolder="./Affy6"
// prefix for naming tghe output vcf file
params.prefix="Affy6_ADME"



chrID = Channel.from( [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22, "X"] )

process sliceChom {
	tag "$id"
	input: 
		val id from chrID
	output: 
		file("*chr*.vcf.gz") into splitted_vcf
		val id into chrom_id

	publishDir params.outfolder, mode:'copy'

	"""
	bcftools view -r $id ${params.vcf} -O z -o ${params.prefix}_chr${id}.vcf.gz
	"""

}

process getStats {
		input: 
			file(vcf) from splitted_vcf
			val id from chrom_id
		output: 
			file("*.csv") into stat_csv


		"""
		bcftools stats $vcf >${params.prefix}_chr${id}.stats 
		get_stats.py --stats ${params.prefix}_chr${id}.stats 
		"""
}

data_stats = stat_csv.collectFile(name: "${params.outfolder}/stat_SNPs_indels_per_file.csv" ,  newLine: false)
