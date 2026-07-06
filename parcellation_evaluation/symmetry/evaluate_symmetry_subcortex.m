%% Symmetry
clear
root = 'D:\research\Parcellation\HCP_Lsym-AVR\Results\Subcortex\subcortex_only';
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
% out = 'D:\research\论文\评估性指标';

in = root;
symmetry = zeros(1,length(labels));
for a = 1:length(labels)
    file_name = dir(fullfile(in,[labels{a},'*']));
    file_name = file_name.name;
    [~,parcellation] = read(fullfile(in,file_name));
    left_parcellation = zeros(size(parcellation));
    right_parcellation = zeros(size(parcellation));

    if~exist('left_mask');left_mask = single(parcellation>=1&parcellation<25);end
    if~exist('right_mask');right_mask = single(parcellation>=25&parcellation<49);end
    
    left_parcellation(parcellation>=1&parcellation<25) = parcellation(parcellation>=1&parcellation<25);
    right_parcellation(parcellation>=25&parcellation<49) = parcellation(parcellation>=25&parcellation<49);
    left_parcellation = left_parcellation(left_parcellation>0);
    right_parcellation = right_parcellation(right_parcellation>0);
    right_parcellation = right_parcellation-24;
    symmetry(a) = bilateral_symmetry_munkres(left_parcellation,right_parcellation,left_mask,right_mask);
end
