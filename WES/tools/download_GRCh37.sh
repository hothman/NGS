DESTINAION=/Destination/folder
for chromosome  in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y 
do
URL=$(echo ftp://ftp.ensembl.org/pub/grch37/current/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.dna.chromosome.${chromosome}.fa.gz) 
wget   --directory-prefix=$DESTINATION  $URL 
done

