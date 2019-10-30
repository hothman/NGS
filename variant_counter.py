#!/usr/bin/python3
__author__ = "Houcemeddine Othman"
__maintainer__ = "Houcemeddine Othman"
__email__ = "houcemoo@gmail.com"

"""
Given a file containing a list of variants in the fomat "Chromosome  Position" 
and a bed file containing a set of genes, it returns the count of each variant per gene
example: 

$ cat data_file.txt 
1 9098553
1 19203977
1 47282784
1 47560343

$ cat bedfile.bed
7 87133178 87342639 ABCB1
10 101542354 101611949 ABCC2
4 89011415 89152474 ABCG2
15 75011882 75017877 CYP1A1
15 75041183 75048941 CYP1A2

$ variant_counter.py --bed bedfile.bed --data data_file.txt 

"""
import argparse

class processBED(object):
	"""docstring for processBED"""
	def __init__(self, bedfile, datafile):
		with open(bedfile, 'r') as mybed: 
			self.bed = mybed.readlines() 
		with open(datafile , 'r') as mydata: 
			self.data = mydata.readlines() 

	def count(self):
		list_of_redundant_genes = []
		for line in self.data: 
			splitted_line = line.split()
			for bedline in self.bed : 
				splitted_line_bed = bedline.split()
				variant_position = int( splitted_line_bed[1] )
				if splitted_line_bed[0] == splitted_line[0] : 
					start_gene = int( splitted_line_bed[1] )
					end_gene = int( splitted_line_bed[2] )
					gene_name = splitted_line_bed[3]
					#print( start_gene , "#######", variant_position, "######",  end_gene )
					if start_gene <= variant_position <= end_gene:
						list_of_redundant_genes.append(gene_name)
		self.list_of_redundant_genes = list_of_redundant_genes

	def output_count(self): 
		for bedline in self.bed : 
			gene_name = bedline.split()[3]
			print(  '{0}\t{1}'.format( gene_name, self.list_of_redundant_genes.count(gene_name )  )    )

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Calculates numbers of variants per genes from a \
												  generic data file")
	
	parser.add_argument("--bed", help="BED file")
	parser.add_argument("--data", help="BED file")
	args = parser.parse_args()
	myobject = processBED(args.bed, args.data)
	myobject.count()
	myobject.output_count()
