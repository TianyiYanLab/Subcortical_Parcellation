% Purpose: export parcel features.
% Input: load(fullfile(repo_path('results/work/CamCan/individualizedParcellation/testInformation.mat')));; load(fullfile(parcelSizePath,[nets{i},'.mat']));
% Output: writetable(dataPrepared,fullfile(outPath,[nets{i},'.csv']));
% Dependencies: MATLAB R2019b; see README.md.
%% 
clear
parcelSizePath = repo_path('results/work/CamCan/individualizedParcellation/ParcelSize');
outPath = repo_path('results/prediction/age/data input');
if ~exist(outPath,'dir'); mkdir(outPath); end
load(fullfile(repo_path('results/work/CamCan/individualizedParcellation/testInformation.mat')));
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
