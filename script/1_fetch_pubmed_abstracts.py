# -*- coding: utf-8 -*-
"""
@author: Fahd Alhazmi July 21, 2017

# To run this script, make sure you have /neurosynth/data/database.txt file
# in data_dir
"""

import requests
from bs4 import BeautifulSoup
import os
import pandas as pd


data_dir = 'data/'

# simple test to make sure we have the neccessary file in place.
# if not, please copy download it from https://github.com/neurosynth/neurosynth-data/raw/master/current_data.tar.gz
# unzip it and move the database.txt to this dir.

assert os.path.exists(
        os.path.join(data_dir,'database.txt')
        ), 'database.txt file is not found in {}'.format(data_dir)

d= pd.read_table(os.path.join(data_dir,'database.txt'))
all_pmid= [int(x) for x in pd.unique(d.id)]

all_abstracts=pd.DataFrame(columns=['pubmid','abstract'])          
all_abstracts['pubmid'] = all_pmid

for row in all_abstracts.iterrows(): #all_pmid[:10]:
    pmid = row[1][0]
    url = 'http://www.ncbi.nlm.nih.gov/pubmed/%s' % pmid
    handler = requests.get(url)
    soup = BeautifulSoup(handler.text, 'html.parser')
    if soup.abstracttext is not None:
        abstract= soup.abstracttext.parent.parent.get_text()
    else:
        abstract= ''
    all_abstracts.loc[all_abstracts['pubmid'] == pmid, 'abstract'] = abstract
    if (row[0] % 10 == 0):
        print(row[0] , '/' , len(all_pmid))


all_abstracts.to_csv(os.path.join(data_dir,'abstracts.csv'), 
             header=False, index=False, encoding='utf-8')