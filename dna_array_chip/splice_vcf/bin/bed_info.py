#!/usr/bin/env python 

import sys
import argparse

def readBed(file, mode="chr"):
	with open(file) as bedfile:
		attributes = bedfile.readlines()[0].split()
		if mode == 'chr':
			sys.stdout.write(attributes[0]) 
		elif mode == 'start': 
			sys.stdout.write(attributes[1])
		elif mode == 'end':
			sys.stdout.write(attributes[2])
		elif mode == 'gene':
			sys.stdout.write(attributes[3])


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("--bed", help="Path to single line bed")
	parser.add_argument("--mode", help="mode: chr, start, end, gene")
	args = parser.parse_args()
	bed="tenp.bed"
	readBed(args.bed, mode=args.mode)