root = 'F:\CB\代码整理\超对齐分区\task_inhomo';
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

for task = 1:7
    [p(task),tbl{task},stats{task}] = friedman((eta2(2:8,cope_domain==task))',1,'off');
end
c = multcompare(stats{1});