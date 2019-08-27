import os
import pandas as pd 

__author__ = "Houcemeddine Othman"
__maintainer__ = "Houcemeddine Othman"
__email__ = "houcemoo@gmail.com"

"""
Use these functions  to merge together different stat files
from snpEff. The problem is that you might end up with different 
headers for different genes. This script will help you to merge them in one 
dataframe.
"""

def read_snpeff_txt(file): 
    with open(file, "r") as txt: 
        lines = txt.readlines()
        if ("#" in lines[0]) and ("#" in lines[1]) :
            return pd.read_csv(file, delimiter="\t", skiprows=1)
        else: 
            return pd.read_csv(file, delimiter="\t")

def concat_snpEff_output(path,  wildcard=".txt"): 
    big_df=pd.DataFrame()
    for root, dirs, files in os.walk(path):
        for filename in files:
            if wildcard in filename:
                df = read_snpeff_txt(path+"/"+filename)
                big_df=big_df.append(df, sort=True)
    big_df = big_df.reset_index()
    return big_df
