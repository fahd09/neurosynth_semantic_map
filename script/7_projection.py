# -*- coding: utf-8 -*-
"""
Created on Mon Feb 29 21:41:41 2016
This script is to implement supplemental projection
@author: Fahd Alhazmi

...
"""

import os
import pandas as pd
import numpy as np
import neurosynth as ns

# supplemental projection code
def afc_sup(X_sup,F,l):
    '''
    X_sub : new data to be projected
    F : Factor scores
    l : lambda values
    '''
    #X_sup2 = X_sup.toarray()/X_sup.toarray().sum(axis=1, keepdims=True, dtype=np.float)
    inv_delta = np.power(l, (-0.5) )
    x,y = X_sup.shape
    # rescale supp data to have sum of 1 in each row
    profile = np.transpose(X_sup.toarray().T * (1./X_sup.toarray().sum(axis=1)))
    ##profile = np.divide(X_sup.toarray(), np.outer( np.transpose(np.sum(X_sup.toarray(), axis=1)), np.ones((1,y))  ) )
    # multiply by transpose of factor scores and eigens   
    f_sup_pre = np.inner(profile, F.T)
    f_sup= np.inner( f_sup_pre ,  np.diag(inv_delta).T)
    f_sup[np.where(np.isnan(f_sup))] = 0    
    return f_sup

def smart_mkdir(data_dir):
    if not os.path.exists(data_dir):
        os.mkdir(data_dir)
    
    
data_dir = 'data'

if os.path.exists(os.path.join(data_dir,'dataset.pkl')):
    dataset = ns.Dataset.load(filename=os.path.join(data_dir,'dataset.pkl') )
else: # this will take a while.. (~15 minutes)
    dataset = ns.Dataset(filename=os.path.join(data_dir,'database.txt'))
    dataset.save(filename=os.path.join(data_dir,'dataset.pkl'))

neurosynth = pd.read_csv(os.path.join(data_dir,'studies_metadata.csv') )
idxassignments = np.loadtxt(os.path.join(data_dir,'idx_assignments_6clusters.txt'), dtype=np.int )

Fis = np.loadtxt(os.path.join(data_dir,'Fis_for_projection.txt') , delimiter=' ')
lambd = np.loadtxt(os.path.join(data_dir,'lambda_for_projection.txt') , delimiter=' ')
X_sup_super = np.zeros((228453, 5)) # final results goes in here
bins= np.linspace(0,228453,271,endpoint=True, dtype=np.int)

# First , project whole brain

for i in range(len(bins))[:-1]:
    select = np.linspace(bins[i],bins[i+1],bins[i+1]-bins[i],endpoint=False, dtype=np.int)
    im=dataset.image_table.get_image_data(ids=list(neurosynth.pubmed), 
                                          voxels=select, 
                                          dense=False) 
    
    # threshold voxels < 10%
    # NOTE that im has a shape of: voxels (rows) x studies (columns)
    vox_sums = np.sum(im.toarray(), axis=1)
    # Now mask out voxels that show up in less than 10% of studies
    goodvox = np.where(vox_sums >= np.percentile(vox_sums, 10))    
    # perform supplemental projection
    X_sup_super[select[goodvox],:] =  afc_sup(im[goodvox], Fis,lambd)
    print(i)

# now save results (if needed)
#np.savetxt(os.path.join(data_dir, 'whole_projection.txt'), 
#               X_sup_super, 
#          fmt='%f', delimiter=',', newline='\n')


#########################
# projection images
#########################

data_dir = 'data/component_maps_maskout_10perc'
smart_mkdir(data_dir)

# write nifti
ns.imageutils.save_img(data=X_sup_super[:,0],filename=os.path.join(data_dir,'whole_brain_comp1.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super[:,1],filename=os.path.join(data_dir,'whole_brain_comp2.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super[:,2],filename=os.path.join(data_dir,'whole_brain_comp3.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super[:,3],filename=os.path.join(data_dir,'whole_brain_comp4.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super[:,4],filename=os.path.join(data_dir,'whole_brain_comp5.nii.gz'),masker=dataset.masker)

#########################
# threshold images
#########################

data_dir = 'data/component_maps_maskout_10perc_mask_2perc_twotails'
smart_mkdir(data_dir)

X_sup_super_thresh = np.zeros((228453, 5)) # final results goes in here
for c in range(5):
    lower = np.where(X_sup_super[:,c] <= np.percentile(X_sup_super[:,c], 2))    
    upper = np.where(X_sup_super[:,c] >= np.percentile(X_sup_super[:,c], 98))    
    both = np.append(lower[0], upper[0])
    X_sup_super_thresh[both,c] = X_sup_super[both,c]

# write nifti
ns.imageutils.save_img(data=X_sup_super_thresh[:,0],filename=os.path.join(data_dir,'whole_brain_comp1.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super_thresh[:,1],filename=os.path.join(data_dir,'whole_brain_comp2.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super_thresh[:,2],filename=os.path.join(data_dir,'whole_brain_comp3.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super_thresh[:,3],filename=os.path.join(data_dir,'whole_brain_comp4.nii.gz'),masker=dataset.masker)
ns.imageutils.save_img(data=X_sup_super_thresh[:,4],filename=os.path.join(data_dir,'whole_brain_comp5.nii.gz'),masker=dataset.masker)


#########################
# Voxel sums
#########################

# First , Voxel sums whole brain

data_dir = 'data/vox_sums'
smart_mkdir(data_dir)

im=dataset.image_table.get_image_data(dense=False) 
vox_sums = im.sum(axis=1)
ns.imageutils.save_img(data=vox_sums,filename=os.path.join(data_dir,'all_vox_sums.nii.gz'),masker=dataset.masker)

# Voxel sums per cluster
clust=7
for c in range(clust)[1:]:
    idx=list(neurosynth.pubmed[idxassignments== (c)])
    im=dataset.image_table.get_image_data(ids=idx,dense=False)     
    vox_sums = im.sum(axis=1)
    ns.imageutils.save_img(data=vox_sums,filename='%s/cluster%i_sums.nii.gz' % (data_dir, c),masker=dataset.masker)

