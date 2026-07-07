%% Hierarchical Clustering of Graph Similarities (Vector Version)
clear
root = 'path/to/your/data\Parcellation\HCP_Lsym-AVR\Results\Subcortex\subcortex_only';
nucleus = {'Subcortex'};
labels = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
% out = 'D:\research\论文\图谱间相似度\dendrogram';

for i = 1:length(nucleus)
    in = root;
    Dice = [];
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
            Dice = [Dice,iteration_Dice_munkres(parcellation1,parcellation2)];
        end
    end

    dist = 1-Dice;
    z = linkage(dist,'average');
%     thresh = 0.7*max(z(:,3));
    h = dendrogram(z,'Orientation','left','ColorThreshold',0.1,'Labels',labels);
    title(nucleus{i});
%     saveas(gcf,fullfile(out,[nucleus{i},'.png'])); 
%     close
end


