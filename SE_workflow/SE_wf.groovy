#!/usr/bin/env nextflow

// Path to reference genome 
params.REFGENOME="~/Desktop/AM933172.fasta"
// Label for generated files
params.LABEL="Enteritidis"
// sample IDs file, one ID per line
params.SAMPLES="~/BILIM/bouthaina_ksibi/simulated_reads/sample_list.txt"
// home for FASTQ files 
params.FASTQs="./simulated_reads/"
// Home for SnpSift 
params.SNPSIFT="~/modules/snpEff"

//listOfPDBs.into { pdb_foldx; pdb_encom }

process generateIndex {
	output: 
		file "*.bt2" into indexes 

	"""
	bowtie2-build -f ${params.REFGENOME} ${params.LABEL}
	"""		
}


// generate a channel from the sample list and replace "\n"  
samples = Channel.fromPath("$params.SAMPLES").splitText()  { it.replaceAll("\n", "") }

process generateBAM {
	publishDir "./", mode:'copy'
	input: 
		val sample from samples.flatMap() 
		file index from indexes 
	output: 
		file "${sample}_ord.bam" into bam_file

	"""
	echo $sample
	file1=\$(ls ${params.FASTQs}/*$sample*R1*)
	file2=\$(ls ${params.FASTQs}/*$sample*R2*)
	# do the alignment
	bowtie2 -x ${params.LABEL} -1 \$file1 -2 \$file2 -S ${sample}.sam
	samtools view -S -b ${sample}.sam > ${sample}.bam
	# order the bam file
	samtools sort ${sample}.bam -o ${sample}_ord.bam
	samtools index ${sample}_ord.bam
	"""

}


process generateBCF {
	input: 
		file bam from bam_file
	output: 
		file "${name}.vcf" into rawVCF
    script:
         name = bam.baseName.replaceFirst(".bam","")

	"""
	# index the bam 
	samtools index ${bam}
	samtools mpileup -uf ${params.REFGENOME} ${bam} | bcftools call -mv| vcfutils.pl varFilter -Q 30 -d 20 -> ${name}.bcf 
	bcftools view ${name}.bcf > ${name}.vcf
	"""
}


process filtervars {
	publishDir "./", mode:'copy'
	input: 
		file vcf from rawVCF
	output: 
    	file "${name}_SNPs_only.recode.vcf"
	script:
       name = vcf.baseName.replaceFirst(".vcf","")

	"""
	java -jar ${params.SNPSIFT}/SnpSift.jar filter "( DP >= 20 ) &( QUAL >= 30 ) & (MQ >= 40) " ${vcf} >${name}_filtered.vcf
	vcftools --vcf ${name}_filtered.vcf --remove-indels --recode --recode-INFO-all --out ${name}_SNPs_only 
	"""
}

// collect all 
//list = bam_file.collect().flatMap()
//list.println()
/*
process random {
	input: 
		val mine from list.flatMap() 

		"""
		echo hello
		"""

}
*/