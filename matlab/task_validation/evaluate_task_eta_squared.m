% Purpose: evaluate task eta squared.
% Input: load(repo_path('data/templates/task_domain_mapping.mat'),'cope_domain');; data = cifti_read(repo_path('data/resources/HCP/group/HCP_S1200_GroupAvg_v1/HCP_S1200_997_tfMRI_ALLTASKS_level2_cohensd_hp200_s2_MSMAll.dscalar.nii'));
% Output: save(fullfile(repo_path('results/task_validation'),'task_eta_squared.mat'),'eta2','eta2_domain','eta2_null','eta2_domain_null','p_diff','cope_domain');
% Dependencies: cifti_read
load(repo_path('data/templates/task_domain_mapping.mat'),'cope_domain');
%% null eta2
data = cifti_read(repo_path('data/resources/HCP/group/HCP_S1200_GroupAvg_v1/HCP_S1200_997_tfMRI_ALLTASKS_level2_cohensd_hp200_s2_MSMAll.dscalar.nii'));
data_subcortex = data.cdata(59413:end,:);
tasknum = size(data_subcortex,2);
assert(numel(cope_domain)==tasknum && all(ismember(cope_domain,1:7)), 'Invalid contrast-to-domain mapping.');
ijk = [];
for i = 3:21
ijk = [ijk;(data.diminfo{1, 1}.models{1, i}.voxlist)'];
end
sz1 = [113 136 113];                         % [113 136 113]
d2  = [91 109 91];         % [91 109 91], from CIFTI
[I,J,K] = ndgrid(0:sz1(1)-1, 0:sz1(2)-1, 0:sz1(3)-1);
v2 = round([I(:) J(:) K(:)] * (1.6/2));         % each 1.6mm voxel -> 2mm voxel (0-based)
rowVol = zeros(d2);                             % 2mm lookup volume: which 2mm voxel sits on which row of X
rowVol(sub2ind(d2, ijk(:,1)+1, ijk(:,2)+1, ijk(:,3)+1)) = (1:size(ijk,1))';
ciftiRow = zeros(size(v2,1),1);          % each 1.6mm voxel -> row index in X (0 = none)
in = all(v2>=0,2) & v2(:,1)<d2(1) & v2(:,2)<d2(2) & v2(:,3)<d2(3);
ciftiRow(in) = rowVol(sub2ind(d2, v2(in,1)+1, v2(in,2)+1, v2(in,3)+1));
atlas = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
% eta2_null(atl, i, c) : eta2 for the atl-th atlas, i-th random partition, c-th task
for atl = 1:8
load(fullfile(repo_path('data/derived/task_null_parcels'),['random_parcels_' atlas{1,atl} '_subcortex.mat']));
nRand = size(parcels_random_all,4);
for i = 1:nRand
atlasnii = parcels_random_all(:,:,:,i);
% voxel -> parcel id, same mapping logic as real data
voxLabel = zeros(size(data_subcortex,1),1);
for j = 1:48
r = unique(ciftiRow(atlasnii==j));  r = r(r>0);   % unique for deduplication
voxLabel(r) = j;
end
use = voxLabel>0;  X = data_subcortex(use,:);  L = voxLabel(use);
for c = 1:tasknum
x = X(:,c);  g = mean(x);  sst = sum((x-g).^2);  ssb = 0;
for id = unique(L)'
xi = x(L==id);  ssb = ssb + numel(xi)*(mean(xi)-g)^2;
end
eta2_null(atl,i,c) = ssb / sst;
end
% Aggregate by domain
for domain = 1:7
eta2_domain_null(atl,i,domain) = mean(eta2_null(atl,i,cope_domain==domain));
end
end
end


root = repo_path('results/group_parcellation/subcortex_only');
atlas = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
eta2 = zeros(8, tasknum);
for i = 1:8
atlasnii = niftiread(fullfile(root,[atlas{i} '_subcortex.nii']));
voxLabel = zeros(size(data_subcortex,1),1);          % each 2mm CIFTI row -> parcel id
for j = 1:48
r = unique(ciftiRow(atlasnii==j)); r = r(r>0);
voxLabel(r) = j;                                 % boundary overlaps are rare; can switch to majority vote if needed
end
use = voxLabel>0;  X = data_subcortex(use,:);  L = voxLabel(use);
for c = 1:tasknum
x = X(:,c);  g = mean(x);  sst = sum((x-g).^2);  ssb = 0;
for id = unique(L)'
xi = x(L==id);  ssb = ssb + numel(xi)*(mean(xi)-g)^2;
end
eta2(i,c) = ssb / sst;
end
end
eta2_domain = zeros(8,7);
for d = 1:7, eta2_domain(:,d) = mean(eta2(:,cope_domain==d),2); end

%% p-values from null distributions
% Input:
%   eta2_domain       : 8 x 7      real values (atlas x domain)
%   eta2_domain_null  : 8 x nRand x 7   null distribution
nRand = size(eta2_domain_null,2);
nAtlas = 8;  nDomain = 7;
% atlas order: 1=GM, 2..8 = VIS,SMN,DAN,VAN,LIM,FPN,DMN

%% (1) difference-null: whether each atlas each domain's real eta2 is significantly higher than random partitions
% Right-tailed: larger real values are better (parcellation better discriminates task activations)
p_diff = nan(nAtlas,nDomain);
for atl = 1:nAtlas
for d = 1:nDomain
nulld = squeeze(eta2_domain_null(atl,:,d));   % 1 x nRand
real  = eta2_domain(atl,d);
p_diff(atl,d) = (sum(nulld >= real) + 1) / (nRand + 1);
end
end




if ~exist(repo_path('results/task_validation'),'dir'); mkdir(repo_path('results/task_validation')); end
save(fullfile(repo_path('results/task_validation'),'task_eta_squared.mat'),'eta2','eta2_domain','eta2_null','eta2_domain_null','p_diff','cope_domain');
