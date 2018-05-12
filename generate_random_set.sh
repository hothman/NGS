# generate a random set of sequences with the same aa content of a fas
#  ./generate_random_set.sh templatefile.fasta outputfile.fasta
echo $FASTA_file
# linearize
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' < $1 >temp_all.fasta

while read peptide
do
echo ">seq" >seq.tmp 
echo $peptide | awk {'print $NF'} >> seq.tmp
nbAA=$(echo $peptide | awk {'print $NF'} | wc -c)
pepstats -sequence seq.tmp  -outfile pepstat.out
makeprotseq -pepstatsfile pepstat.out -amount 1 -length $nbAA -outseq outseq

cat outseq | tr a-z A-Z >>$2 

done < temp_all.fasta
rm temp_all.fasta outseq seq.tmp
