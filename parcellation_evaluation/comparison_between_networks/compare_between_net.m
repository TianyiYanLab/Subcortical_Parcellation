%% Whole Nucleus Cluster Map Similarity (NII Version)
clear
root = 'path/to/your/data\newResult\new_parcellation';
labels = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
out = 'path/to/your/data\newResult\figure2\group_similar_2C';

in = root;
Dice = ones(length(labels),length(labels));
for a = 1:length(labels)
    file_name = dir(fullfile(in,[labels{a},'*']));
    file_name = file_name.name;
    [~,parcellation1] = read(fullfile(in,file_name));
    parcellation1 = parcellation1(find(parcellation1));
    for b = a+1:length(labels)
        file_name = dir(fullfile(in,[labels{b},'*']));
        file_name = file_name.name;
        [~,parcellation2] = read(fullfile(in,file_name));
        parcellation2 = parcellation2(find(parcellation2));
        % calculate Dice
        Dice(a,b) = iteration_Dice(parcellation1,parcellation2);
    end
end
Dice = Dice + Dice'-1;
figure(1)
% heatmap({'FPN','DMN','DAN','LIM','VAN','SMN','VIS'},{'FPN','DMN','DAN','LIM','VAN','SMN','VIS'},Dice_left, 'Colormap',hot, 'GridVisible','off');
% heatmap({'DAN','DMN','FPN','LIM','SMN','VAN','VIS','Cortex'},{'DAN','DMN','FPN','LIM','SMN','VAN','VIS','Cortex'},Dice_left, 'Colormap',hot, 'GridVisible','off');
heatmap(labels,labels,Dice, 'Colormap',hot, 'GridVisible','off','CellLabelColor','none');
caxis([min(min(Dice)) max(max(Dice))]);
title('Subcortex');
saveas(gcf,fullfile(out,'Subcortex.png')); 
close

%% 全核团图谱间相似度（nii版）和聚类树画一起的版本
clear
root = 'path/to/your/data\Parcellation\HCP_Lsym-AVR\Results\Subcortex\subcortex_only';
labels = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
out = 'path/to/your/data';

in = root;
Dice = ones(length(labels),length(labels));
for a = 1:length(labels)
    file_name = dir(fullfile(in,[labels{a},'*']));
    file_name = file_name.name;
    [~,parcellation1] = read(fullfile(in,file_name));
    parcellation1 = parcellation1(find(parcellation1));
    for b = a+1:length(labels)
        file_name = dir(fullfile(in,[labels{b},'*']));
        file_name = file_name.name;
        [~,parcellation2] = read(fullfile(in,file_name));
        parcellation2 = parcellation2(find(parcellation2));
        % calculate Dice
%         Dice(a,b) = iteration_Dice(parcellation1,parcellation2);
        Dice(a,b) = iteration_Dice_munkres(parcellation1,parcellation2);
    end
end
Dice = Dice + Dice'-1;
Dice_resort = Dice+diag(inf+zeros(1,length(Dice)));
Dice_resort = Dice_resort([3 5 2 1 4 7 6],[3 5 2 1 4 7 6]);
figure('position',[100,100,400,300])
% heatmap({'FPN','DMN','DAN','LIM','VAN','SMN','VIS'},{'FPN','DMN','DAN','LIM','VAN','SMN','VIS'},Dice_left, 'Colormap',hot, 'GridVisible','off');
% heatmap({'DAN','DMN','FPN','LIM','SMN','VAN','VIS','Cortex'},{'DAN','DMN','FPN','LIM','SMN','VAN','VIS','Cortex'},Dice_left, 'Colormap',hot, 'GridVisible','off');
heatmap(labels([3 5 2 1 4 7 6]),labels([3 5 2 1 4 7 6]),Dice_resort, 'Colormap',cool, 'GridVisible','off');
caxis([min(min(Dice)) max(max(Dice))]);
title('Subcortex');
saveas(gcf,fullfile(out,'Subcortex.png')); 
close