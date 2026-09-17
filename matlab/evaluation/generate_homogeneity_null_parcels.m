% Purpose: generate 100 homogeneity null parcellations per atlas.
% Input: atlas MAT masks under data/; random_parcels external function.
% Output: parcels_random_all MAT arrays.
% Dependencies: MATLAB R2019b and exact random_parcels implementation.
clear

msk_dir = repo_path('results/work/results/noPCA mean 0thresh/Subcortex/subcortex_only');
out_dir = repo_path('results/work/results/Evaluation/noPCA mean 0thresh/homogeneity/random_parcels');
rng(0);
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};

for i = 1:length(labels)
    mskFile = fullfile(msk_dir,[labels{i},'_subcortex.mat']);
    MM=100; % Number of randomizations
    parcels_random_all=random_parcels(mskFile,MM);

    % Save parcellation specific random parcels
    [~,Prefix]=fileparts(mskFile);
    parcelFile=['random_parcels_',Prefix,'.mat'];
    save(fullfile(out_dir,parcelFile),'parcels_random_all');
end
