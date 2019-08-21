#!/usr/bin/python3
__author__ = "Houcemeddine Othman"
__maintainer__ = "Houcemeddine Othman"
__email__ = "houcemoo@gmail.com"

import pandas as pd 
import argparse

parser = argparse.ArgumentParser(description="Filter a BED file by removing all the genes given in another BED file (4th column)")
parser.add_argument("-l1", help="BED to be filtered")
parser.add_argument("-l2", help="BED file containing genes to remove")
parser.add_argument("-s", help="elements containing this string will be removed, optional.") 

def read_list(file):
	with open(file, 'r') as file:
		lines = file.read().splitlines()
	return lines

def filter_list(to_filter_list, filter_list, *args):
	#reformat bed file for filter_list 
	gene_names = []
	for region in filter_list: 
		gene_names.append( region.split()[3] )

	filtered_elements=[]
	for element in to_filter_list:
		if element.split()[3] not in gene_names : 
			filtered_elements.append(element)
	to_return_list = []
	if args != (): 
		for element in filtered_elements: 
			if args[0] not in element: 
				to_return_list.append(element)
	else: 
		to_return_list = filtered_elements
	return to_return_list

if __name__ == "__main__":
	args = parser.parse_args()
	list1 = read_list(args.l1)
	list2 = read_list(args.l2)
	try:
		retained_genes = filter_list(list1, list2, args.s)
	except: 
		retained_genes = filter_list(list1, list2)
	for genes in retained_genes: 
		print(genes)
