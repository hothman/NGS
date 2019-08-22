#!/usr/bin/python3
import argparse

parser = argparse.ArgumentParser(description="arranges the text output file of SnPeff to include only the gene with canonical transcript. Assumes one gene per file")
parser.add_argument("--inputFile", help="SnpEff text output file")
parser.add_argument("--tag", help="tag")


def parseSnpEff(input_file, tag=""): 
	with open(input_file, 'r') as snpeff: 
		lines = snpeff.read().splitlines()
	#if tag != "": 
	mylines=[]
	for index,line in enumerate(lines): 
		if index in [1,2] : 
			mylines.append( line.split())
	if tag != "":
		print(tag)
		mylines[0].append("Tag")
		mylines[1].append(tag)

	for line in mylines:
		line=[str(element) for element in line]
		print(','.join( line  ))
		

if __name__ == "__main__":
	args = parser.parse_args()
	try:
		parseSnpEff(input_file=args.inputFile, tag=args.tag)
	except: 
		parseSnpEff(input_file=args.inputFile)
