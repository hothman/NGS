#!/usr/bin/env nextflow

// path to bed file containing list of genes to extract
params.BED="../simulate_vcf/core_proper.bed"

VCF = Channel.fromPath( '/home/houcem/tmp_science/coverage_chip/NGS/dna_array_chip/simulate_vcf/*.vcf.gz' )

genes = Channel.fromPath("$params.BED").splitText()  { it.replaceAll("\n", "") }

	//#bcftools view -r $chr:$start-$end $path_to_vcf -Oz -o $outputfile 
    //#tabix  $outputfile

params.upstream_buffer = 1000
params.downstream_buffer = 1000

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
	conda 'bioconda::bedtools=2.30.0'
	  
	input: 
		file bed from bed_adme
		each file(vcf) from VCF
	output: 
		file("*_sliced.vcf") into sliced_vcfs

	"""
	gene_name=\$(awk {'print \$4'} $bed)
	chromosome_id=\$(awk {'print \$1'} $bed)
	intersectBed -a $vcf -b $bed -header >\${gene_name}_chr\${chromosome_id}_sliced.vcf
	"""
}


process verifySizeOfVCF {
	errorStrategy 'ignore'  // isVcfEmpty.py returns exit status 1 if empty

	input: 
		file(vcf) from sliced_vcfs
	output: 
		path("*.vcf", includeInputs:true) into sliced_non_empty_vcfs  

	"""
	bcftools stats $vcf >file.stats
	isVcfEmpty.py --stats file.stats
	"""

}

process compressIndex {
	conda 'bioconda::tabix=1.11'
	publishDir './sliced_vcfs' , mode: 'move', overwrite: true

	input:
		file(vcf) from sliced_non_empty_vcfs
	output:
		file("*.vcf.gz") into compressedVcf
		file("*.tbi") into indexes

	"""
	bgzip  $vcf 
	tabix ${vcf}.gz
	"""
}

/*
process annotatedbSNP {
	conda 'bioconda::gatk4=4.2.0.0'

	input:
		file(vcf) from compressedVcf
		file(index) from indexes

	"""
	bcftools annotate -c ID \
-a ~/var-calling/reference_data/dbsnp.138.chr20.vcf.gz \
~/var-calling/results/variants/na12878_q20.recode.vcf.gz \
> ~/var-calling/results/annotation/na12878_q20_annot.vcf
	"""


}
*/