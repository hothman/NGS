#!/usr/bin/env python 
import sys
import argparse

def readStats(bcf_tools_stats): 
	""" returns exit status 0 if stat file contains 0 variants"""
	with open(bcf_tools_stats, 'r') as stats:
		lines = stats.readlines()
	for line in lines: 
		if "number of records:" in line:
			if  int(line.split()[-1]) == 0:
				print(int(line.split()[-1]))
				sys.exit(1)

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("--stats", help="Path to bcftools stats file")
	args = parser.parse_args()
	readStats(args.stats)