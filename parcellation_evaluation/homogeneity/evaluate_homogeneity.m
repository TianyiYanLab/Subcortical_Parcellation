%% Compute homogeneity
clear
msk_dir = 'path/to/your/data\Subcortex\subcortex_only';
nucleus_dir = 'path/to/your/data\nucleus_mask';
out_dir = 'path/to/your/data\homogeneity';
TS_dir = 'path/to/your/data\Data\subcortex_TS';

random_parcel_dir = fullfile(out_dir,'random_parcels');
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
sub = dir(TS_dir);
sub(1:2) = [];

% % Indices of 14 nuclei in the whole subcortical mask
[~,subcortex_msk] = read(fullfile(msk_dir,'GM_subcortex.nii'));
subcortex_msk(~~subcortex_msk) = 1;
subcortex_msk_ind = find(subcortex_msk);
clear subcortex_msk
% load('E:\Êý¾Ý\function7T_timeseries\100610\subcortex_TS.mat')% example data
% nucleus_in_subcortex_ind = cell(1,14);
% for i = 1:14
%     [~,nucleimsk] = read(fullfile(nucleus_dir,[subcortex_TS.order{i},'.nii']));
%     nuclei_ind = find(nucleimsk);
%     lia = ismember(subcortex_msk_ind,nuclei_ind);
%     nucleus_in_subcortex_ind{i} = lia;
% end
% save(fullfile(out_dir,'nucleus_in_subcortex_ind.mat'),'nucleus_in_subcortex_ind');
load(fullfile(out_dir,'nucleus_in_subcortex_ind.mat'));
gmFile = fullfile(msk_dir,'GM_subcortex.nii');
MM = 100;
for i = 1:length(sub)
    load(fullfile(TS_dir,sub(i).name,'subcortex_TS.mat'));
    TS = zeros(size(subcortex_TS.data{1},1),length(subcortex_msk_ind));
    for j = 1:length(nucleus_in_subcortex_ind)
        TS(:,nucleus_in_subcortex_ind{j}) = subcortex_TS.data{j};
    end
    out = fullfile(out_dir,'result',sub(i).name);
    if ~exist(out)
        mkdir(out);
    end
    for j = 1:length(labels)
        if ~exist(fullfile(out,[labels{j},'_subcortex.mat']))
            mskFile = fullfile(msk_dir,[labels{j},'_subcortex.nii']);
            parcelFile = fullfile(random_parcel_dir,['random_parcels_',labels{j},'_subcortex.mat']);
            [exp_avg,exp_avg_null,z]=do_homogeneity(TS,mskFile,parcelFile,gmFile,MM);
            save(fullfile(out,[labels{j},'_subcortex.mat']),'exp_avg','exp_avg_null','z');
            fprintf('sub:%d/%d,net:%d/%d\n',i,170,j,8);
        end
    end
end