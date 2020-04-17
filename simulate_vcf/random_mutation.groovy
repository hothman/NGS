#!/usr/bin/env nextflow

/* Ttakes a reference genome fasta files and a bed file and generates a 
	random mtations only for the genes in the BED file
	requires vcfy 
*/

// reference genome file
params.REFSEQ='./Path_to_fasta_ref_files'

// mutation rate 
params.MUTATUINRATE=0.1

// BED file 
params.BED="./path_to_bed_file/test.bed" 
folder_fasta = Channel.fromPath("$params.REFSEQ")
bed_file = Channel.fromPath("$params.BED").splitText()

process slice_genes {
	input:
		val line from bed_file.flatMap() 

	output:
		file "*.vcf" into vcfout

	publishDir "./", mode:'copy'
	"""
	echo '$line' >temp
	chnumber=\$(awk '{print \$1}' temp)
	echo \$chnumber
	starting=\$(awk '{print \$2}' temp)
	ending=\$(awk '{print \$3}' temp)
	geneName=\$(awk '{print \$4}' temp)
	vcfy -l \$starting  -h \$ending  -m ${params.MUTATUINRATE} ${params.REFSEQ}/Homo_sapiens.GRCh37.dna.chromosome.\$chnumber.fa > \${geneName}_dummy.vcf
	"""	
}
