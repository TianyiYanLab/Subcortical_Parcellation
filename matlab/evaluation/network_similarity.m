% Purpose: network similarity.
% Input: [~,parcellation1] = read(fullfile(root,[labels{Net1},'_subcortex']));; [~,parcellation2] = read(fullfile(root,[labels{Net2},'_subcortex']));
% Output: save(fullfile(outPath,[nucleus{iNuc},'.mat']),'Dice')
% Dependencies: read
%% Similarity Between Nodal Group Networks (NII Version)
clear
root = repo_path('results/group_parcellation/subcortex_only');
nucleus = {'SUBCORTEX','ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
labels = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
outPath = repo_path('results/evaluation/network_similarity');
SubcortexInds = {[0:47],[0,1,24,25],[2,3,26,27],[4,5,6,28,29,30],...
    [7,8,9,10,11,31,32,33,34,35],[12,13,14,36,37,38],...
    [15,16,17,18,19,20,39,40,41,42,43,44],...
    [21,22,23,45,46,47]};
for iNuc = 1:length(nucleus)
    currNucLabels = SubcortexInds{iNuc}+1;
    Dice = ones(length(labels),length(labels));
    for Net1 = 1:length(labels)
%         file_name = dir(fullfile(in,[labels{Net1},'_subcortex']));
%         file_name = file_name.name;
        [~,parcellation1] = read(fullfile(root,[labels{Net1},'_subcortex']));
        parcellation1 = parcellation1(ismember(parcellation1,currNucLabels));
        net1Parcellation = parcellation1;
        net1Parcellation(net1Parcellation>24) = net1Parcellation(net1Parcellation>24)-24+length(currNucLabels)/2;
        net1Parcellation = net1Parcellation-min(net1Parcellation)+1;
        for Net2 = Net1+1:length(labels)
            [~,parcellation2] = read(fullfile(root,[labels{Net2},'_subcortex']));
            parcellation2 = parcellation2(ismember(parcellation2,currNucLabels));
            net2Parcellation = parcellation2;
            net2Parcellation(net2Parcellation>24) = net2Parcellation(net2Parcellation>24)-24+length(currNucLabels)/2;
            net2Parcellation = net2Parcellation-min(net2Parcellation)+1;
            % calculate Dice
            Dice(Net1,Net2) = iteration_Dice_munkres(net1Parcellation,net2Parcellation);
        end
    end
    save(fullfile(outPath,[nucleus{iNuc},'.mat']),'Dice')
%     Dice = Dice + Dice'-1;
end

