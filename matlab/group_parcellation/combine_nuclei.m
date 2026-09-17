% Purpose: combine nuclei.
% Input: [~,GM_mask] = read(Schaefer400_file);; [~,left_mask] = read(fullfile(nucleiMaskPath,[nucleus{j},'_LEFT.nii']));
% Output: mat2nii(subcortex_parcellation,fullfile(out_dir,'subcortex_only',[nets{i},'_subcortex.nii']),size(subcortex_parcellation),32,Schaefer400_file);; mat2nii(subcortex_parcellation,fullfile(out_dir,'cortex_subcortex',[nets{i},'_cortex_subcortex.nii']),size(subcortex_parcellation),32,Schaefer400_file);
% Dependencies: mat2nii, read
%% All nuclei combine
clear
parcellation_dir = repo_path('results/group_parcellation');
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
Schaefer400_file = repo_path('data/resources/template/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1.6mm.nii');
nucleiMaskPath = repo_path('data/templates/nucleus_masks');
out_dir = repo_path('results/group_parcellation');
if ~exist(fullfile(out_dir,'subcortex_only'),'dir'); mkdir(fullfile(out_dir,'subcortex_only')); end
if ~exist(fullfile(out_dir,'cortex_subcortex'),'dir'); mkdir(fullfile(out_dir,'cortex_subcortex')); end
[~,GM_mask] = read(Schaefer400_file);
cortex_label = GM_mask(GM_mask>0);
for i = 1:length(nets)
    subcortex_parcellation = zeros(size(GM_mask));
    cum_ind = 0;
    for j = 1:length(nucleus)
        nucleus_dir = fullfile(parcellation_dir,nucleus{j});
        [~,left_mask] = read(fullfile(nucleiMaskPath,[nucleus{j},'_LEFT.nii']));
        [~,nuclei_parcellation] = read(fullfile(nucleus_dir,[nets{i},'_',nucleus{j},'.nii']));
        subcortex_parcellation(left_mask~=0) = nuclei_parcellation(left_mask~=0)+cum_ind;
        cum_ind = cum_ind + length(unique(nuclei_parcellation(left_mask~=0)));
    end
    
    for j = 1:length(nucleus)
        nucleus_dir = fullfile(parcellation_dir,nucleus{j});
        [~,right_mask] = read(fullfile(nucleiMaskPath,[nucleus{j},'_RIGHT.nii']));
        [~,nuclei_parcellation] = read(fullfile(nucleus_dir,[nets{i},'_',nucleus{j},'.nii']));
        subcortex_parcellation(right_mask~=0) = nuclei_parcellation(right_mask~=0)+cum_ind;
        cum_ind = cum_ind + length(unique(nuclei_parcellation(right_mask~=0)));
    end
    mat2nii(subcortex_parcellation,fullfile(out_dir,'subcortex_only',[nets{i},'_subcortex.nii']),size(subcortex_parcellation),32,Schaefer400_file);

    % add Schaefer400
    subcortex_parcellation(GM_mask>0) = cortex_label + cum_ind;
    mat2nii(subcortex_parcellation,fullfile(out_dir,'cortex_subcortex',[nets{i},'_cortex_subcortex.nii']),size(subcortex_parcellation),32,Schaefer400_file);
end
