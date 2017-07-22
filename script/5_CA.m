% This script will do the final CA to use for clustering analysis

clear all

addpath script/helpers
addpath data/

data_dir = 'data';
load([data_dir '/dtm_9987sparsity.mat']) %% Make sure this is correct
data_stemmed=data;
clear data

[lambda,tau,~,fi,~,~,~,fj,~,~]=corresp(data_stemmed);

clear data_stemmed
Fi20=fi(:,1:20);
Fj20=fj(:,1:20);

save([data_dir '/FiFjLambda_20comps_fulltau_lambda'],'Fi20','Fj20','tau','lambda')
