#!/bin/bash

cutoffAA=60
outputFASTA=filtred_by_length.fasta 

  
signalp -t euk -M 10 -f short OneSeq.fa >out 
	sig=$( tail -n 1 out | awk {'print $10'} )

if [ "$sig" = "Y" ] 
then
	val1=$( tail -n 1 out | awk {'print $3'} )
	val2=$( tail -n 1 out | awk {'print $5'} )
	val3=$( tail -n 1 out | awk {'print $7'} )
	min=$(printf "$val1\n$val2\n$val3" | sort -nrk 1 | head -n 1)
	sequence=$(tail -n 1 OneSeq.fa)
	mature=$(echo $sequence |  awk -v var=$min  '{print substr($1, var ,100000)}')
	
	# filter by number of residues 
	nbAA=$(echo $mature | wc -c)
	
	if [ "$nbAA" -lt "$cutoffAA"  ]
		then 
			echo "Valid mature peptide" 
			head -n 1 OneSeq.fa >> $outputFASTA
			echo $mature  >> $outputFASTA
				fi

else 
	nbAA=$(tail -n 1 OneSeq.fa | wc -c)
		if [ "$nbAA" -lt "$cutoffAA"  ]
			then 
				cat OneSeq.fa >> $outputFASTA
					fi
				
	 
fi

