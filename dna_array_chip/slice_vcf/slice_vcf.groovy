#!/usr/bin/env nextflow

// path to bed file containing list of genes to extract
params.BED="../../../data/all_ADME.bed"

VCF = Channel.fromPath( '../simulate_vcf/*.vcf.gz' )
params.INDEXHOME= '/home/houcem/tmp_science/coverage_chip/NGS/dna_array_chip/simulate_vcf' 
genes = Channel.fromPath("$params.BED").splitText()  { it.replaceAll("\n", "") }

		/* In this bloc, you need to specify the association between the files and the 
		 Chromosome Ids
		*/
vcf_map_chromosome = [ "dummy_chr22.vcf.gz":"22",
						"dummy_chr21.vcf.gz":"21",]



params.upstream_buffer = 1000000
params.downstream_buffer = 1000000

process GetBed {
	input: 
		val gene from genes.flatMap() 
	output: 
		file("*_adme.bed") into bed_adme


	"""
	echo $gene > tmp.bed
	gene_name=\$(awk {'print \$4'}  tmp.bed)
	chr=\$(awk {'print \$1'}  tmp.bed)
	bed_info.py  --bed tmp.bed --upstream ${params.upstream_buffer} --downstream  ${params.downstream_buffer} --outputbed \${gene_name}_chr\${chr}_adme.bed
	"""
}


// WARNING: ethe process ignores errors assuming that it is due 
// to unm,atching chromosome ID in deb and vcf file 

process SliceVCF {
	//conda 'bioconda::bcftools'
	publishDir './sliced_vcfs' , mode: 'copy', overwrite: true
	//echo true
	errorStrategy 'ignore'

	input: 
		each file(vcf) from VCF
		file(bed) from bed_adme

	output: 
		file("*_sliced.vcf.gz") optional true into sliced_vcfs

	script:
		chrom_id_from_map = vcf_map_chromosome[vcf.name]

		def m = bed.name =~ /chr[0-9]{1,2}/
		matching_string = m.find()?m.group():"not matched"
		chrom_id = matching_string.replaceAll("chr", "")

		if (chrom_id == chrom_id_from_map)
			"""
			gene_name=\$(awk {'print \$4'} $bed)
			ln -s ${params.INDEXHOME}/${vcf}.tbi
			bcftools view  -R $bed -O z $vcf -o \${gene_name}_chr${chrom_id}_sliced.vcf.gz
			"""
}


process IndexVCF {
	//conda 'bioconda::bcftools'
	publishDir './sliced_vcfs' , mode: 'move', overwrite: true

	input:
		file(vcf) from sliced_vcfs
	output:
		file("*.tbi") into indexes

	"""
	bcftools index $vcf -t 
	"""
}


