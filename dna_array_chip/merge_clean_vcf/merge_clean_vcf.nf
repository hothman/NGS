#!/usr/bin/env nextflow

VCFs = Channel.fromPath( '../simulate_vcf/simulate_with_samples/*.vcf.gz' )
params.SAMPLELIST = '../simulate_vcf/simulate_with_samples/samples.txt'     // you can get this using bcftools query -l 1kgp_22_region.vcf.gz >samples.txt
params.OUTPUTVCF = "ADME_H3Africa_allGenes.vc.gz"
params.OUTPUTDIR = "./output"

process removeSamples {
	input: 
		file(vcf) from VCFs

	output:
		file("*_subsetted.vcf.gz") into subsetted_vcfs
		file("*.csi") into index_file

	script: 
		name = vcf.baseName.replaceFirst(".vcf","")
		println name

	"""
	bcftools view -S ${params.SAMPLELIST} -O z -o ${name}_subsetted.vcf.gz $vcf 
	bcftools index ${name}_subsetted.vcf.gz
	"""
}

process concatVcfs {
	input:
		file(vcf) from subsetted_vcfs.collect()
		file(csi) from index_file.collect()

	output:
		file("concat.vcf.gz") into concatenated_deduplicated_vcf 
		file("concat.vcf.gz.csi") into index_concatenated_deduplicated_vcf
	"""
	
	bcftools concat -D -a -Oz -o concat.vcf.gz $vcf 
	bcftools index concat.vcf.gz
	"""
}


process sortVCF {
	publishDir params.OUTPUTDIR , mode: 'copy', overwrite: true
	input: 
		file(vcf) from concatenated_deduplicated_vcf

	output:
		file(params.OUTPUTVCF) 
		file("*.csi")

	"""
	bcftools sort -Oz -o ${params.OUTPUTVCF} $vcf
	bcftools index ${params.OUTPUTVCF}
	"""
}



