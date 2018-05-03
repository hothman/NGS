#!/bin/bash
file=$1

# linearize the fasta sequences
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' < $file >temp.fasta


while IFS= read -r line
do
	
        # display $line or do somthing with $line
	id=$(echo $line | awk {'print $1'} ) 
	seq=$(echo $line | awk {'print $NF'} ) 
	echo $id > OneSeq.fa
	echo $seq >> OneSeq.fa
	#printf '%s\n' "$line"
done < temp.fasta

rm temp.fasta OneSeq.fa

