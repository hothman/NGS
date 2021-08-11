#!/usr/bin/env python 

import sys
import argparse

def readBed(file, upstream, downstream, output ):
	with open(file, 'r') as bedfile:
		attributes = bedfile.readlines()[0].split()
		chr = attributes[0]
		start = str(int(attributes[1]) - int(upstream) )  
		if int(start) < 0:
			start = str(1)
		print(start)
		end = str( int(attributes[2]) +  int(downstream) ) 
		gene = attributes[3]
		new_bed = '\t'.join([chr, start, end, gene])
	with open( output, 'w') as outputbed: 
		outputbed.write(new_bed)



if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("--bed", help="Path to single line bed")
	parser.add_argument("--upstream", help="offset_upstream")
	parser.add_argument("--downstream", help="offset_downstream")
	parser.add_argument("--outputbed", help="output BED file")
	args = parser.parse_args()
	bed="tenp.bed"
	readBed(args.bed, args.upstream, args.downstream, args.outputbed )