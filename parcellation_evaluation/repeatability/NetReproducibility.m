clear
RepParcellationPath = 'D:\research\HCP_parcellation_Lsym-AVR\HCP\All nets reproducibility\100 iterations group parcellation';
nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};

AllNetsGroup1 = zeros(17799,7,100);
AllNetsGroup2 = zeros(17799,7,100);
for net = 1:length(nets)
    CurrNetGroup1 = [];
    CurrNetGroup2 = [];
    for nuc = 1:length(nucleus)
        load(fullfile(RepParcellationPath,nets{net},nucleus{nuc}));
        CurrNucGroup1 = [group1_L_parcellation;group1_R_parcellation+max(group1_L_parcellation,[],'all')];
        CurrNucGroup2 = [group2_L_parcellation;group2_R_parcellation+max(group2_L_parcellation,[],'all')];
        if nuc~=1
            CurrNetGroup1 = [CurrNetGroup1;CurrNucGroup1+max(CurrNetGroup1,[],'all')];
            CurrNetGroup2 = [CurrNetGroup2;CurrNucGroup2+max(CurrNetGroup2,[],'all')];
        else
            CurrNetGroup1 = CurrNucGroup1;
            CurrNetGroup2 = CurrNucGroup2;
        end
    end
    AllNetsGroup1(:,net,:) = CurrNetGroup1;
    AllNetsGroup2(:,net,:) = CurrNetGroup2;
end
%%
for i = 1:100
    tic
    CurrRepGroup1 = AllNetsGroup1(:,:,i);
    CurrRepGroup2 = AllNetsGroup2(:,:,i);
    [IntraNetDice(:,i),InterNetDice(:,i),SimMat(:,:,i)] = RandomGroupDice(CurrRepGroup1,CurrRepGroup2);
    toc
    fprintf('iteration %d finished\n',i)
end
save(fullfile('D:\research\HCP_parcellation_Lsym-AVR\HCP\All nets reproducibility\AllRepDice.mat'),'InterNetDice','IntraNetDice','SimMat')
function [IntraNetDice,InterNetDice,SimMat] = RandomGroupDice(Group1,Group2)
% Group1,Group2 = #label of subcortical voxel ¡Á #nets
for i = 1:size(Group1,2)
    for j = 1:size(Group2,2)
        SimMat(i,j) = iteration_Dice_munkres(Group1(:,i),Group2(:,j));
%         [Dice,assignment] = iteration_Dice_munkres(Group1(:,i),Group2(:,j));
    end
end
IntraNetDice = diag(SimMat);
InterNetDice = SimMat-diag(diag(SimMat));
InterNetDice = InterNetDice(:);
InterNetDice(InterNetDice==0) = [];
end


