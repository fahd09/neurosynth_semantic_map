% In this script, we do the split-half analysis on stemmed version

clear all
s = RandStream('mt19937ar','Seed',149);
RandStream.setGlobalStream(s);

%%%%%%%%%%%
% change those to your local gdrive
addpath script/helpers
data_dir = 'data';
%%%%%%%%%%%


load([data_dir '/dtm_9987sparsity.mat'])
data_stemmed=data;
clear data
iterations=1000;         % how many iterations for the split-half ?
nf2k=20; %number of factors to keep.

camat_fj = zeros(20,20,iterations);

% If you are running this for the first time, ignore this line
% otherwise, uncomment one of the following two lines
%load([data_dir '/camat_fj_20comps_1000iter'])

% This is just in case things went so bad;
% it will only start from where it stopped
% start = length(nonzeros(camat_fi(1,1,:))) + 1;
start = 1;

disp([num2str(iterations) ' iterations of split-half analysis are about to start..'])
[obs,words]=size(data_stemmed);
disp(start)

for iii=start:iterations,
    % Fj
    
    SH_obs1= randperm(obs,obs/2);    % split-half 1
    SH_obs1=sort(SH_obs1);
    SH_obs2= setdiff(1:obs,SH_obs1);     % split-half 2
    
    % Make sure we have nonzero halves, otherwise go to next iteration
    if exist(find(sum(data_stemmed(SH_obs1,:))==0)) || exist(find(sum(data_stemmed(SH_obs2,:))==0)),
        continue
    end
    
    try
        disp('doing CA1 FJ')
        [~,Fj1]=efficient_corresp(data_stemmed(SH_obs1,:),nf2k);
        disp('doing CA2 FJ')
        [~,Fj2]=efficient_corresp(data_stemmed(SH_obs2,:),nf2k);
    catch
        continue
        disp('skipped:')
        disp(iii)
    end
    
    camat_fj(:,:,iii) = corr(Fj1,Fj2);    
    save([data_dir '/camat_fj_20comps_1000iter'],'camat_fj')
    
    disp(iii)
end
