#!/usr/bin/python3
__author__ = "Houcemeddine Othman"
__maintainer__ = "Houcemeddine Othman"
__email__ = "houcemoo@gmail.com"

import re 
from os.path import basename
import argparse
import csv

parser = argparse.ArgumentParser(description="arranges the text output file of SnPeff to include only the gene with canonical transcript. Assumes one gene per file")
parser.add_argument("--snpeffCSV", help="SnpEff csv output file")
parser.add_argument("--snpeffTXT", help="SnpEff text output file, assumes the name is in the following format <gene_name>.vcf.gz.txt")
parser.add_argument("--out", help="CSV output file")
parser.add_argument("--tag", help="tag to add to csv output")


effects = {"gene_name":"Missing data", "transcript_id":"Missing data",  "DEL":"0", "INS":"0", "SNP":"0", "MISSENSE":"0", "SILENT":"0", "EXON":"0", "INTRON":"0","FRAME_SHIFT":"0", "START_GAINED":"0",
"START_LOST":"0", "SYNONYMOUS_START":"0", "NON_SYNONYMOUS_START":"0", "STOP_GAINED":"0", "SYNONYMOUS_STOP":"0", "STOP_LOST":"0", "FRAMESHIFT_VARIANT":"0",
"SPLICE_SITE_ACCEPTOR":"0", "SPLICE_SITE_DONOR":"0", "SPLICE_SITE_REGION":"0",
"NONE":"0", "CHROMOSOME":"0", "CUSTOM":"0", "CDS":"0", "INTERGENIC":"0", "INTERGENIC_CONSERVED":"0", "UPSTREAM":"0", "UTR_5_PRIME":"0", "UTR_5_DELETED":"0", "INTRAGENIC":"0",  
"GENE":"0", "TRANSCRIPT":"0", "EXON_DELETED":"0", "NON_SYNONYMOUS_CODING":"0", "SYNONYMOUS_CODING":"0",  
"CODON_CHANGE":"0", "CODON_INSERTION":"0", "CODON_CHANGE_PLUS_CODON_INSERTION":"0", "CODON_DELETION":"0", "CODON_CHANGE_PLUS_CODON_DELETION":"0", 
"RARE_AMINO_ACID":"0",  "INTRON_CONSERVED":"0", "UTR_3_PRIME":"0", "UTR_3_DELETED":"0",
"DOWNSTREAM":"0", "REGULATION":"0"}


fields = ["Variantss by type", "Effects by functional class", "Count by effects", "Count by genomic region"]
def readOutput(input_file): 
	with open(input_file, 'r') as snpeff: 
		lines = snpeff.read().split('#')
	return lines[2:]

def read_parse_txt(snpEff_textfile):
	with open(snpEff_textfile, 'r') as snpefftxt: 
		lines = snpefftxt.read().split('\n')
	try : 
		gene_name = basename(snpEff_textfile).replace(".sliced.vcf.gz.txt",'')
	except: 
		print("text output should be in the format <gene_name>.vcf.gz.txt")
	for line in  lines[2:]: 
		if gene_name in line and ("protein_coding" in line) :
			transcript_id =(line.split()[2])
	effects["gene_name"] = gene_name
	effects["transcript_id"] = transcript_id
	return effects

def parse(lines): 
	for bloc in lines: 
		for effect in list( effects.keys() ) :
			for field in fields: 
				if field in bloc: 
					splitted_bloc = bloc.upper().split('\n')
					for line in splitted_bloc: 
						if re.search(r'\b' + effect + r'\b', line) : 
							spliced_line =  line.split(",") 
							effects[effect]=spliced_line[1].strip()  
	return effects

if __name__ == "__main__":
	args = parser.parse_args()
	effects =  read_parse_txt(args.snpeffTXT)
	lines = readOutput(args.snpeffCSV)
	effects=parse(lines)
	if args.tag != None: 
		effects["tag"] = args.tag

	toCSV = [effects]
	keys = list(toCSV[0].keys() )
	with open(args.out, 'w') as output_file:
		dict_writer = csv.DictWriter(output_file, keys)
		dict_writer.writeheader()
		dict_writer.writerows( toCSV  )
