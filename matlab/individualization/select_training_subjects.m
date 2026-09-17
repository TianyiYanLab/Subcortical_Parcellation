% Purpose: select training subjects.
% Input: sub_information = readtable(repo_path('data/resources/CamCan/subInfo.csv'));
% Output: save(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),...
% Dependencies: MATLAB R2019b; see README.md.
%% 
clear
sub_information = readtable(repo_path('data/resources/CamCan/subInfo.csv'));
FCS_path = repo_path('results/work/CamCan/individualizedParcellation/FCS');
sub = dir(fullfile(FCS_path,'*.mat'));
% Reject misalignment rather than assigning ages to a different subject.
fileIDs = erase(string({sub.name})','.mat');
assert(ismember('Sub_ID',sub_information.Properties.VariableNames), 'subInfo requires Sub_ID.');
assert(isequal(fileIDs,string(sub_information.Sub_ID)), 'Subject file order differs from subInfo rows; align by ID before proceeding.');
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
save(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),...
    'trainSFiles','trainSubInformation','trainInd','sFiles')
