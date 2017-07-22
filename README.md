# neurosynth_semantic_map

This repository contains all the analysis code to reproduce/explore the (currently) bioarxiv manuscript "The Latent Semantic Space and Corresponding Brain Regions of the Functional Neuroimaging Literature"[doi: 10.1101/157826](https://doi.org/10.1101/157826).

### Requirementes & dependances

Download packages and libraries as required. The last successful run was conducted using R version 3.3.3  and Python 3.6.0 (through Anaconda enviroment). 

Beside that, you will need to download [this neurosynth dataset](https://github.com/neurosynth/neurosynth-data/blob/master/archive/data_0.5.February_2015.tar.gz) (5 February, 2015) and unzip the file, then move 'database.txt' to 'data/' folder here. This file is > 100MB and cannot be uploaded to Github. In cases you want to work with the latest Neurosynth data release, the script should work fine but you might see different results.

### Running the script

Hopefully, file names in 'script' folder are clear enough. You should run them in the same order if you want to run this project from scratch. However, you don't need to as most inputs/outputs are already in the data/ folder. Oh.. the document-term matrix (dtm) is 270MB and cannot be uploaded in this repo but you still can download it from [here](https://drive.google.com/open?id=0By2zoBIfyKtTdDNDTm05M1Y2WUk). Again, you should download it to the 'data' folder.

### Need help?

Just open a new issue and I will do my best to help.