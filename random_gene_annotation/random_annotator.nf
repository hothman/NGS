#!/usr/bin/env nextflow 

gene_bed_file =Channel.fromPath("${params.gene_bed_file}")
N = Channel.from( params.N ) 

process sample_genes {

	input: 
		file(bed_file) from gene_bed_file
		val number from N
	output: 
		file("*.bed") into subset_of_genes
	
	"""
	echo $bed_file
	shuf -n $number  $bed_file >subsample.bed
	"""
	}

lines = subset_of_genes.splitText()
//lines.subscribe { println it } 

process slice_genes {
	maxForks 50
	input:
		val line from lines.flatMap() 
	output: 
		file ("*.vcf.gz") into sliced_vcf

	"""
	echo '$line' >mybedfile.bed 
	gene_name=\$(awk {'print \$4'} mybedfile.bed)
        sed -i 's/ /\t/g' mybedfile.bed
	chr_number=\$(awk {'print \$1'} mybedfile.bed )
	vcf_to_splice=\$(ls "${params.VCF}"/*\$chr_number"${params.suffix}")
	bcftools view \$vcf_to_splice  --regions-file mybedfile.bed  -O z -o \$gene_name.sliced.vcf.gz
	mv mybedfile.bed \$gene_name.bed 
	
	"""	
}

// annotation with SnpEff 
process snpeff_annotation {
	maxForks 50
	memory '4 GB'
    	executor 'slurm'
        input:
            file(vcf) from sliced_vcf
        output:
             file("*_ann.vcf.gz") into vcf_snpeff
             file("*.csv") into summary_csv
	     file("*.txt") into summary_txt
	
	publishDir "${params.outdir}", mode: 'move'

	"""
	name=\$(basename $vcf *.vcf.gz)
	out=\$(echo \$name"_sneff.vcf.gz") 
        java -Xmx4g  -jar "${params.snpeff}"/snpEff.jar  hg19 -canon -csvStats  mystats.csv -stats mystats  $vcf   > \$out"_ann.vcf.gz"
	mv *.csv \$name".csv"
	mv *.txt \$name".txt"
	       
        """
}
