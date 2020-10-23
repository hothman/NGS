#!/usr/bin/env nextflow

// Path to reference genome 
params.REFGENOME="/home/houcemeddine/BILIM/NGS/WES/refgenome/refGenomeGRCh38.fa.gz"
// Label for generated files
params.LABEL="hg"
// sample IDs file, one ID per line
params.SAMPLES="data/list_samples.txt"
// home for FASTQ files 
params.FASTQs="/home/houcemeddine/BILIM/NGS/WES/FASTQs/"
params.BWATHREADS=2
params.GATKHOME="/home/houcemeddine/modules/gatk-4.1.8.1"

// generate a channel from the sample list and replace "\n"  
samples = Channel.fromPath("$params.SAMPLES").splitText()  { it.replaceAll("\n", "") }

//refgenomeChannel = Channel.fromPath( "$params.REFGENOME" )

process generateBAM {
	memory { 4.GB * task.attempt }

	publishDir "./", mode:'copy'
	input: 
		val sample from samples.flatMap() 
		//file ref_genome from refgenomeChannel 
	output: 
		file "${sample}_unsorted.bam" into bam_file
		val sample into sample_id
	"""
	echo $sample
	file1=\$(ls ${params.FASTQs}/*$sample*r1*)
	file2=\$(ls ${params.FASTQs}/*$sample*r2*)
	ID=\$(echo ${sample}ID)
	bwa mem -t ${params.BWATHREADS}  ${params.REFGENOME} \$file1 \$file2  | samtools addreplacerg -r ID:\$ID -r PL:Illumina - |  samtools view -Sb - > ${sample}_unsorted.bam
	"""
}


//samples = Channel.fromPath("$params.SAMPLES").splitText()  { it.replaceAll("\n", "") }

process markDuplicates {
	input: 
		file sorted_bam from bam_file
		val sample from sample_id
	output:
		file "${sample}_dedup.bam" into dedup_bams
		val sample from sample_id
	"""
	gatk MarkDuplicatesSpark  --input $sorted_bam \
							  --output ${sample}_dedup.bam \
							  --metrics-file ${sample}_meterics.txt 
	"""

}


process genRecalibrationTable {
	input:
		bam from dedup_bams
		val sample from sample_id

	"""
	gatk BaseRecalibrator --input $bam \
						  --output ${sample}.recal.table
	"""



}


process run_create_recalibration_table {
    tag { "${params.project_name}.${sample_id}.rCRT" }
    memory { 8.GB * task.attempt }
    publishDir "${params.out_dir}/${sample_id}", mode: 'copy', overwrite: false

    input:
    set val(sample_id), file(bam_file), file(bam_file_index) from md_bam

    output:
    set val(sample_id), file("${sample_id}.md.bam"), file("${sample_id}.md.bai"), file("${sample_id}.recal.table")  into recal_table
    
    script:
    """
    ${params.gatk_base}/gatk --java-options  "-Xmx${task.memory.toGiga()}g" \
    BaseRecalibrator \
    --input ${bam_file} \
    --output ${sample_id}.recal.table \
    --TMP_DIR ${params.gatk_tmp_dir} \
    -R ${params.ref_seq} \
    --known-sites ${params.dbsnp} \
    --known-sites ${params.known_indels_1} \
    --known-sites ${params.known_indels_2}
    """
}

process run_recalibrate_bam {
    tag { "${params.project_name}.${sample_id}.rRB" }
    memory { 8.GB * task.attempt }
    publishDir "${params.out_dir}/${sample_id}", mode: 'copy', overwrite: false

    input:
    set val(sample_id), file(bam_file), file(bam_file_index), file(recal_table_file) from recal_table

    output:
    set val(sample_id), file("${sample_id}.md.recal.bam")  into recal_bam
    set val(sample_id), file("${sample_id}.md.recal.bai")  into recal_bam_index
    
    script:
    """
    ${params.gatk_base}/gatk --java-options  "-Xmx${task.memory.toGiga()}g" \
     ApplyBQSR \
    --input ${bam_file} \
    --output ${sample_id}.md.recal.bam \
    --TMP_DIR ${params.gatk_tmp_dir} \
    -R ${params.ref_seq} \
    --create-output-bam-index true \
    --bqsr-recal-file ${recal_table_file}
    """
}

process run_samtools_stats {
    tag { "${params.project_name}.${sample_id}.rSS" }
    memory { 4.GB * task.attempt } 
    cpus { "${params.bwa_threads}" }
    publishDir "${params.out_dir}/${sample_id}", mode: 'copy', overwrite: false

    input:
    set val(sample_id), file(bam_file) from recal_bam

    output:
    set val(sample_id), file("${sample_id}.md.recal.stats")  into recal_stats

    """
    ${params.samtools_base}/samtools stats  \
    --threads ${params.bwa_threads} \
    ${bam_file} > ${sample_id}.md.recal.stats  \
    """
}


workflow.onComplete {

    println ( workflow.success ? """
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}