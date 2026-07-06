%% 
clear
parcelSizePath = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\ParcelSize';
outPath = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\parcelSize2AgePrediction';
load(fullfile('D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\testInformation.mat'));
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
for i = 1:length(nets)
    load(fullfile(parcelSizePath,[nets{i},'.mat']));
    ParcelSize = ParcelSize';
    dataPrepared = testSubInformation;
    for j = 1:size(ParcelSize,2)
        dataPrepared = addvars(dataPrepared,ParcelSize(:,j),'NewVariableNames', ['roi',num2str(j)]);
    end
    writetable(dataPrepared,fullfile(outPath,[nets{i},'.csv']));
end