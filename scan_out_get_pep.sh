
FASTA_file="reformatted_raw_orfs.fasta"  # the fasta file
INPUT_DATA="sample.dat"     # signalp output 
outputFASTA="retained_sequences.fasta"  # output 
cutoffAA=60   # cutoff for length
cutoffcharge=1   # cutoff for charge
# linearize
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' < $FASTA_file >temp.fasta

while read peptide; do
echo $peptide >temp 
  sig=$(awk {'print $10'} temp)
  #echo $sig
  if [ "$sig" = "Y" ] 
then
	val1=$( tail -n 1 temp | awk {'print $3'} )
	val2=$( tail -n 1 temp | awk {'print $5'} )
	val3=$( tail -n 1 temp | awk {'print $7'} )
	min=$(printf "$val1\n$val2\n$val3" | sort -nrk 1 | head -n 1)
	id=$(awk {'print $1'} temp)
	#echo $id
	sequence=$(grep -w $id temp.fasta | head -n 1| awk {'print $NF'})
	#echo $sequence
	#echo $sequence
	mature=$(echo $sequence | awk -v var=$min  '{print substr($1, var ,100000)}')

	## filter by number of residues 
	nbAA=$(echo $mature | wc -c)

	if [ "$nbAA" -lt "$cutoffAA"  ]
		then 
	
			echo ">$id" > fasta_temp.fasta 
			echo $mature >> fasta_temp.fasta
			pepstats -sequence fasta_temp.fasta  -outfile pepstat.out
			charge=$(grep "Charge   ="  pepstat.out | awk {'print $NF'})
			if (( $(echo "$charge $cutoffcharge" | awk '{print ($1 >= $2)}') )) 
				then 
					echo "the charge is effective" 
					echo $charge
					cat   fasta_temp.fasta >> $outputFASTA
					fi		
				fi
				
else 
	id=$(awk {'print $1'} temp)
	sequence=$(grep -w  $id temp.fasta | head -n 1 | awk {'print $NF'})
	#echo $sequence
	nbAA=$(echo $sequence | wc -c)
	if [ "$nbAA" -lt "$cutoffAA"  ]
		then 
		echo ">$id" > fasta_temp.fasta
		echo $sequence >> fasta_temp.fasta
		pepstats -sequence fasta_temp.fasta  -outfile pepstat.out
		charge=$(grep "Charge   ="  pepstat.out | awk {'print $NF'})
		if (( $(echo "$charge $cutoffcharge" | awk '{print ($1 >= $2)}') )) 
					then 
					cat   fasta_temp.fasta >> $outputFASTA
					fi	
		
			fi


fi
done < $INPUT_DATA
