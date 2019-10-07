#!usr/bin/env nextflow 

//              A workflow to Calculate that samples n positions 
//      randomly from a vcf file and output the weighted fst calculated by 
//      plink for m number of iterations. Requires bcftools, plink and shuf
//      User needs to specify stratification file according to plink requirement (within_file.txt). 

VCF=Channel.fromPath("myvcf.vcf.gz")
within_file=Channel.fromPath("within_file.txt")
number_of_samples = Channel.from( 100 )
number_of_iterations = 10
output_path="/Path/To/output/Folder/fst_values.txt"

// add IDs to  column  
process add_IDs  {
        input:
             file vcf from VCF
        output:
             file "snps.map" into map_file
             file "myvcf.vcf.gz" into myvcf
        """
        bcftools annotate --set-id "%CHROM\\_%POS\\_%REF\\_%FIRST_ALT"  $vcf -O z >myvcf.vcf.gz
        plink --vcf  myvcf.vcf.gz  --recode  --out myplink_files 
        cut -f 2 myplink_files.map  > snps.map
        """
                 }

process sample_vcf {
        input:
             file map  from map_file
             file vcf from myvcf
             file within from within_file
             val n from number_of_samples
             each number from 1..number_of_iterations
        output:
                file "fst" into fst
        """
        shuf -n $n $map  > snps.subset.map
        plink --vcf  $vcf --extract snps.subset.map --make-bed --out forfstcalculation
        plink --bfile   forfstcalculation --fst --within $within --recode --out myfstout${number}
        grep "Weighted Fst estimate:"   myfstout${number}.log |cut -d " " -f4  >fst
        """
// outputs values to a file
fst.collectFile(name: output_path , newLine: false)

