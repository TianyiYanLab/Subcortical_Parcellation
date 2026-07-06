%% ciftiRow
data = cifti_read('D:\HCP\group\HCP_S1200_GroupAvg_v1\HCP_S1200_997_tfMRI_ALLTASKS_level2_cohensd_hp200_s2_MSMAll.dscalar.nii');
data_subcortex = data.cdata(59413:end,:);
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

%% task inhomogeneity
atlas = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
root = 'F:\CB\代码整理\超对齐分区\task_inhomo';
tasknum = size(data_subcortex,2);
inhomo_all = [];
sd_task_all = [];
for i = 1:length(atlas)
    atlas_dir = fullfile(root,[atlas{i} '_subcortex.nii']);
    atlasnii = niftiread(atlas_dir);
    roisize = [];
    sumstd_task = [];
    for j = 1:48
        roiMask = atlasnii==j;
        roiRows = ciftiRow(roiMask);
        roiRows = roiRows(roiRows>0);
        task_data = data_subcortex(roiRows,:);
        sd_task_all(i,j,:) = std(task_data,0,1);
        roisize(j) = size(roiRows,1);
        sumstd_task(j,:) = roisize(j).*std(task_data,0,1);
    end
    inhomo_all(i,:) = sum(sumstd_task,1)./sum(roisize,'all');
    for domain = 1:7
        inhomo_domain(i,domain) = mean(inhomo_all(i,cope_domain==domain));
    end
end

% Not averaging across 48 parcels, but looking at domains
for i = 1:8
    for j = 1:7
        st_task_domain(i,:,j) = mean(sd_task_all(i,:,cope_domain==j),3);
    end
end
% compare
h = [];
p = [];
for i = 2:8
    for j = 1:7
        [h(i,j),p(i,j)] = ttest(squeeze(st_task_domain(1,:,j)), squeeze(st_task_domain(i,:,j)), 'Tail', 'right');
    end
end

% Not averaging across 48 parcels, average across domains
st_task_avg = squeeze(mean(st_task_domain,3));
for i = 2:8
    [havg(i),pavg(i)] = ttest(st_task_avg(1,:),st_task_avg(i,:), 'Tail', 'right');
end

%% null
atlas = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
for atl = 1:8
    load(['random_parcels_' atlas{1,atl} '_subcortex.mat']);
    inhomo_all = [];
    sd_task_all = [];
    for i = 1:size(parcels_random_all,4)
        atlasnii(:,:,:) = parcels_random_all(:,:,:,i);
        roisize = [];
        sumstd_task = [];
        for j = 1:48
            roiMask = atlasnii==j;
            roiRows = ciftiRow(roiMask);
            roiRows = roiRows(roiRows>0);
            task_data = data_subcortex(roiRows,:);
            sd_task_all(i,j,:) = std(task_data,0,1);
            roisize(j) = size(roiRows,1);
            sumstd_task(j,:) = roisize(j).*std(task_data,0,1);
        end
        inhomo_all(i,:) = sum(sumstd_task,1)./sum(roisize,'all');
        for domain = 1:7
            inhomo_domain_null(atl,i,domain) = mean(inhomo_all(i,cope_domain==domain));
        end
    end
end

%% compare 7 domains

for i = 1:8
    for j = 1:7
        [h(i,j),p(i,j)] = ttest(squeeze(inhomo_domain_null(i,:,j)), inhomo_domain(i,j), 'Tail', 'right');
    end
end
% Distribution
for i = 1:8
  for j = 1:7
    nd = squeeze(inhomo_domain_null(i,:,j));
    p_null(i,j) = mean(nd <= inhomo_domain(i,j));               % Left-tailed: observed is more homogeneous than random, smaller p = better
    Z_null(i,j) = (mean(nd) - inhomo_domain(i,j)) / std(nd);    % Effect size (>0 = more homogeneous than random)
  end
end

%% compare task
inhomo_domain_null_avg = mean(inhomo_domain_null,3);
inhomo_domain_avg = mean(inhomo_domain,2);
for i = 1:8
        [h_null(i),p_null(i)] = ttest(squeeze(inhomo_domain_null_avg(i,:)), inhomo_domain_avg(i,1), 'Tail', 'right');
end
% Distribution
for i = 1:8
  for j = 1:7
    nd = squeeze(inhomo_domain_null(i,:,j));
    p_null(i,j) = mean(nd <= inhomo_domain(i,j));               % Left-tailed: observed is more homogeneous than random, smaller p = better
    Z_null(i,j) = (mean(nd) - inhomo_domain(i,j)) / std(nd);    % Effect size (>0 = more homogeneous than random)
  end
end