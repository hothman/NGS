#!/usr/bin/env nextflow

// path to bed file containing list of genes to extract
params.BED="all_ADME.bed"

VCF = Channel.fromPath( '../simulate_vcf/*.vcf.gz' )
params.INDEXHOME= 'simulate_vcf' 
genes = Channel.fromPath("$params.BED").splitText()  { it.replaceAll("\n", "") }

	//#bcftools view -r $chr:$start-$end $path_to_vcf -Oz -o $outputfile 
    //#tabix  $outputfile

params.upstream_buffer = 1000000
params.downstream_buffer = 1000000

process getbed {
	input: 
		val gene from genes.flatMap() 
	output: 
		file("*_adme.bed") into bed_adme


	"""
	echo $gene > tmp.bed
	gene_name=\$(awk {'print \$4'}  tmp.bed)
	bed_info.py  --bed tmp.bed --upstream ${params.upstream_buffer} --downstream  ${params.downstream_buffer} --outputbed \${gene_name}_adme.bed
	"""
}


process sliceVCF {
	conda 'bioconda::bcftools'
	errorStrategy 'ignore'
	publishDir './sliced_vcfs' , mode: 'copy', overwrite: true
	input: 
		file bed from bed_adme
		each file(vcf) from VCF

	output: 
		file("*_sliced.vcf.gz") optional true into sliced_vcfs

	"""
	gene_name=\$(awk {'print \$4'} $bed)
	chromosome_id=\$(awk {'print \$1'} $bed)
	chromosome_in_vcf=\$(bcftools query -f '%CHROM\n' $vcf | uniq)
	ln -s ${params.INDEXHOME}/${vcf}.tbi
	if [ \$chromosome_id -eq \$chromosome_in_vcf ]
	then
		bcftools view  -R $bed -O z $vcf -o  \${gene_name}_chr\${chromosome_id}_sliced.vcf.gz
		
	fi
	
	"""
}



process compressIndex {
	conda 'bioconda::bcftools'
	publishDir './sliced_vcfs' , mode: 'move', overwrite: true

	input:
		file(vcf) from sliced_vcfs
	output:
		file("*.tbi") into indexes

	"""
	bcftools index $vcf -t 

	"""
}

