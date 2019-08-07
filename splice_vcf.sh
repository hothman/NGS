while IFS= read -r line
do
echo $line >temp
chr=$(awk {'print $2'} temp)
flag=`echo chr$chr`
start=$(awk {'print $5'} temp  )
end=$(awk {'print $6'} temp )

gene_name=$(awk {'print $1'} temp  )
outputfile=$(echo "$chr-$gene_name-1KG_ref.vcf.gz")


flag=$(echo "*chr"$chr".*.vcf.gz")
path_to_vcf=`ls ~/1k-2014/VCF/$flag`


bcftools view -r $chr:$start-$end $path_to_vcf -Oz -o $outputfile
tabix  $outputfile

done <gene_list.txt
