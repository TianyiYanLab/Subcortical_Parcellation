%% 
clear
sub_information = readtable('D:\research\HCP_parcellation_Lsym-AVR\CamCan\subInfo.csv');
FCS_path = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\FCS';
sub = dir(fullfile(FCS_path,'*.mat'));
% Sort by age
age = sub_information.Age;
[~,ageIndY2O] = sort(age);
% Take 100 equally spaced points
sampleInd = linspace(1,length(age),100);
sampleInd = round(sampleInd);

trainInd = ageIndY2O(sampleInd);
trainSubInformation = sub_information(trainInd,:);
sFiles = {sub.name}';
trainSFiles = sFiles(trainInd);
save('D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\trainingSet.mat',...
    'trainSFiles','trainSubInformation','trainInd','sFiles')