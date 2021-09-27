#!/usr/bin/env python 

import argparse

def processStatFile(stat_file):
	IDs = []
	snps = []
	indels = []
	with open(stat_file, "r") as mystats:
		lines = mystats.readlines()
		for line in lines:
			# extract ID
			if "ID	0" in line:
				ID = line.split()[-1].replace("_ADME_African.vcf.gz", "")
				IDs.append(ID)
			elif "number of SNPs:" in line:
				nb_snps = line.split()[-1]
				snps.append(int(nb_snps))
			elif "number of indels:" in line:
				nb_indels = line.split()[-1]
				indels.append(int(nb_indels))
	with open("stats.csv", "w") as outputfile: 
		outputfile.write("{0}\t{1}\t{2}\n".format(ID, nb_snps, nb_indels))


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description=" Provide the stat file from bcftool")
	# add long and short argument
	parser.add_argument("--stats", help="Stat file")
	args = parser.parse_args()
	processStatFile(args.stats)
