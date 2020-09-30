#!/usr/bin/python3
__author__ = "Houcemeddine Othman"
__maintainer__ = "Houcemeddine Othman"
__email__ = "houcemoo@gmail.com"

from bs4 import BeautifulSoup
import pandas as pd 

def searchTables(soup, gene_table_id_attribute, pheno_table_id_attribute):
    genes = soup.findAll('table', {"id":gene_table_id_attribute})
    phenotypes = soup.findAll('table', {"id":pheno_table_id_attribute})
    return genes, phenotypes

def extracHtmlTable(table):
    """
    Table is an object retuned by findAll
    """
    output_dic = {}
    if len(table) == 1 : # sanity check to make sure the object in table1 contains one table 
        cell = table[0]
        th = cell.find_all('th')  # th for table header
        header = [col.text.strip('\n') for col in th]  # extract header labels 
        nb_cols = len(header)
        raws  = cell.find_all('td')  # get all raws of the table
        cols = [raws[i::nb_cols] for i in range(nb_cols)] # create the container list for all the colms in the table example [['gene1'. 'gene2'], [12, 65],[date1, date2]]
        for column, column_name in zip(cols, header) : 
            data_in_column = [element.text for element in column] 
            try: 
                data_in_column = [int(element) for element in data_in_column ]  # to convert any string ints to int type
            except: 
                pass
            output_dic[column_name] = data_in_column  
    return output_dic
