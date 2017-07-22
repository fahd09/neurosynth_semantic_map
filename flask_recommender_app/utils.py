#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  6 23:41:31 2017

@author: Home
"""

import os
import pandas as pd
import numpy as np
from scipy.spatial.distance import cdist


def get_closest_studies(query = 10191322):
    #data_dir = '/Users/Home/gdrive/Lababdi/Neurosynth/data/'
    #neurosynth = pd.read_csv(os.path.join(data_dir,'studies_metadata.csv'), index_col=0)
    #idxassignments = np.loadtxt(os.path.join(data_dir,'idx_assignments_6clusters.txt'), dtype=np.int )
    #Fis = np.loadtxt(os.path.join(data_dir,'Fis_for_projection.txt') , delimiter=' ')
    if type(query) != int:
        query = int(query)
    qindx = np.where(neurosynth['pubmed'].values==query)[0][0]
    dists = cdist(Fis, Fis[qindx][None,:])
    closest = np.argsort(dists, axis=0)[1:].flatten()
    neurosynth.iloc[closest[:10]]


#neurosynth_full_dataset = neurosynth.merge(ds, on=['pubmed','title'])
#neurosynth_full_dataset.to_csv('../data/studies_metadata.csv')
