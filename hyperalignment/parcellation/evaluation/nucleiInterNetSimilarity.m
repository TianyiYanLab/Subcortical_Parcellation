%% Similarity Between Nodal Group Networks (NII Version)
clear
root = 'D:\research\Parcellation\hyperalignment\parcellation\results\subcortex_only';
nucleus = {'SUBCORTEX','ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
labels = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
outPath = 'D:\research\Parcellation\hyperalignment\parcellation\evaluation';
SubcortexInds = {[0:49],[0,1,25,26],[2,3,27,28],[4,5,6,29,30,31],...
    [7,8,9,10,11,32,33,34,35,36],[12,13,37,38],...
    [14,15,16,17,18,19,39,40,41,42,43,44],...
    [20,21,22,23,24,45,46,47,48,49]};
for iNuc = 1:length(nucleus)
    currNucLabels = SubcortexInds{iNuc}+1;
    Dice = ones(length(labels),length(labels));
    for Net1 = 1:length(labels)
%         file_name = dir(fullfile(in,[labels{Net1},'_subcortex']));
%         file_name = file_name.name;
        [~,parcellation1] = read(fullfile(root,[labels{Net1},'_subcortex']));
        parcellation1 = parcellation1(ismember(parcellation1,currNucLabels));
        net1Parcellation = parcellation1;
        net1Parcellation(net1Parcellation>25) = net1Parcellation(net1Parcellation>25)-25+length(currNucLabels)/2;
        net1Parcellation = net1Parcellation-min(net1Parcellation)+1;
        for Net2 = Net1+1:length(labels)
            [~,parcellation2] = read(fullfile(root,[labels{Net2},'_subcortex']));
            parcellation2 = parcellation2(ismember(parcellation2,currNucLabels));
            net2Parcellation = parcellation2;
            net2Parcellation(net2Parcellation>25) = net2Parcellation(net2Parcellation>25)-25+length(currNucLabels)/2;
            net2Parcellation = net2Parcellation-min(net2Parcellation)+1;
            % calculate Dice
            Dice(Net1,Net2) = iteration_Dice_munkres(net1Parcellation,net2Parcellation);
        end
    end
    save(fullfile(outPath,[nucleus{iNuc},'.mat']),'Dice')
%     Dice = Dice + Dice'-1;
end

