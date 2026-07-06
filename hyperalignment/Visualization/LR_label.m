%% First, make the left and right labels symmetric
clear
original_parcellation_path = 'D:\research\Parcellation\HCP\Results\Subcortex\subcortex_only';
new_parcellation_path = 'D:\research\论文\图谱可视化';
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};

for i = 1:length(labels)
    [~,p] = read(fullfile(original_parcellation_path,[labels{i},'_subcortex.nii']));
    parcel_num = length(unique(p))-1;
    new_p = p;
    for j = parcel_num/2+1:parcel_num
        new_p(new_p == j) = j-parcel_num/2;
    end
    mat2nii(new_p,fullfile(new_parcellation_path,[labels{i},'_subcortex.nii']),size(new_p),32,fullfile(original_parcellation_path,[labels{i},'_subcortex.nii']));
end

%% Visualize using BNV
clear
parcellation_dir = 'D:\research\论文\图谱可视化';
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};

for j = 1:8
    curr_out_path = fullfile(parcellation_dir,nets{j});
    if~exist(curr_out_path);mkdir(curr_out_path);end
    filename = [parcellation_dir,'\',nets{j},'_subcortex'];
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'\R2L.mat'],[curr_out_path,'\R2L.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'\Bottom2up.mat'],[curr_out_path,'\Bottom2up.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'\Up2Bottom.mat'],[curr_out_path,'\Up2Bottom.png']);
    BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv',[filename,'.nii'],[parcellation_dir,'\Front.mat'],[curr_out_path,'\Front.png']);
end