% Purpose: bnv.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
%% Visualize with BNV
clear
parcellation_dir = repo_path('results/work/Visualize');
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};

for j = 1:8
    curr_out_path = fullfile(parcellation_dir,nets{j});
    if~exist(curr_out_path);mkdir(curr_out_path);end
    filename = [parcellation_dir,'/',nets{j},'_subcortex'];
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'/R2L.mat'],[curr_out_path,'/R2L.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'/Bottom2up.mat'],[curr_out_path,'/Bottom2up.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'/Up2Bottom.mat'],[curr_out_path,'/Up2Bottom.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'/Front.mat'],[curr_out_path,'/Front.png']);
end
