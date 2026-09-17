% Purpose: evaluate symmetry.
% Input: load(fullfile(FCS_path,subList(indSub).name,[nucleus{indNucleus},'.mat']));; [~,left_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
% Output: save(fullfile(out_path,'multiK_symmetry.mat'),'symmetry_sym');
% Dependencies: SpectralClustering_multiK_Larry, read
%% Symmetry
clear
mask_path = repo_path('data/templates/nucleus_masks');
FCS_path = repo_path('results/hyperalignment/forward');
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
out_path = repo_path('results/work/hyperalignment/Ksolution/symmetry');
if ~exist(out_path,'dir'); mkdir(out_path); end
subList = dir(FCS_path);
subList(1:2,:) = [];
% labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
max_k = 10;
symmetry_sym = zeros(9,7);
for indNucleus = 1:7
    tic
    all_sub_FCS = cell(2,1);
    fprintf('loading FCS_mat\n')
    for indSub = 1:length(subList)
        load(fullfile(FCS_path,subList(indSub).name,[nucleus{indNucleus},'.mat']));
        all_sub_FCS{1,1} = [all_sub_FCS{1,1},FCS{1,1}];
        all_sub_FCS{2,1} = [all_sub_FCS{2,1},FCS{2,1}];
    end
    fprintf('all FCS mat loaded\n')
    lFcs = mean(all_sub_FCS{1,1},2);
    lFcs = recon_symmat(lFcs);
    lFcs = lFcs+eye(size(lFcs));
    rFcs = mean(all_sub_FCS{2,1},2);
    rFcs = recon_symmat(rFcs);
    rFcs = rFcs+eye(size(rFcs));
    
    leftW = double(lFcs);
    leftW = leftW.*(leftW>0);
    rightW = double(rFcs);
    rightW = rightW.*(rightW>0);
    
    left_parcellation = SpectralClustering_multiK_Larry(leftW,max_k,3);
    right_parcellation = SpectralClustering_multiK_Larry(rightW,max_k,3);
    
    [~,left_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
    [~,right_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_RIGHT.nii']));
    for indK = 1:9
        symmetry_sym(indK,indNucleus) = bilateral_symmetry_munkres(left_parcellation(:,indK),right_parcellation(:,indK),left_mask,right_mask);
    end
    toc
    fprintf('%d finished\n',indNucleus)
end
save(fullfile(out_path,'multiK_symmetry.mat'),'symmetry_sym');
