% Purpose: build individual fingerprints.
% Input: GM_mask = niftiread(repo_path('results/work/rGM_cortex_subcortex.nii'));; sub_mask = niftiread(repo_path('results/work/CamCan/individualizedParcellation/rGM_subcortex.nii'));
% Output: save(fullfile(FCS_path,[sub(i).name(1:12),'.mat']),'s');; save(fullfile(repo_path('results/work/CamCan/individualizedParcellation'),'troubleSub.mat'),'nanSub','allZeroSub')
% Dependencies: MATLAB R2019b; see README.md.
%% Whole nucleus similarity
clear
TS_path = repo_path('data/camcan/preprocessed');
sub = dir(fullfile(TS_path,'*.gz'));
FCS_path = repo_path('results/work/CamCan/individualizedParcellation/FCS');
if ~exist(FCS_path,'dir'); mkdir(FCS_path); end
GM_mask = niftiread(repo_path('results/work/rGM_cortex_subcortex.nii'));
GM_mask(isnan(GM_mask))=0;
GM_mask(GM_mask~=0)=1;
sub_mask = niftiread(repo_path('results/work/CamCan/individualizedParcellation/rGM_subcortex.nii'));
sub_mask(isnan(sub_mask))=0;
sub_mask(sub_mask~=0)=1;

allZeroSub = [];
nanSub = [];
for i = 1:length(sub)
    tic
    sub_ima=niftiread(fullfile(TS_path,sub(i).name));
    s = cal_fcs(sub_mask,GM_mask,sub_ima);
    if isempty(s)
        warning('Subject %d TS has all-zero points\n',i)
        allZeroSub = [allZeroSub;sub(i).name(1:12)];
        continue
    elseif sum(isnan(s),'all')
        warning('Subject %d FCS has NaN values\n',i)
        nanSub = [nanSub;sub(i).name(1:12)];
        continue
    else
        save(fullfile(FCS_path,[sub(i).name(1:12),'.mat']),'s');
    end
    fprintf('Subject %d completed\n',i);
    toc
end
save(fullfile(repo_path('results/work/CamCan/individualizedParcellation'),'troubleSub.mat'),'nanSub','allZeroSub')
