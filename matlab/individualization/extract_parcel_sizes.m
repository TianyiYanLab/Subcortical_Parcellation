% Purpose: extract parcel sizes.
% Input: load(fullfile(currNetPath,sub(j).name));; subInformation = readtable(repo_path('data/resources/CamCan/subInfo.csv'));
% Output: save(fullfile(outPath,[nets{i},'.mat']),'ParcelSize');; save(fullfile(repo_path('results/work/CamCan/individualizedParcellation/testInformation.mat')));
% Dependencies: MATLAB R2019b; see README.md.
%%
clear
rootPath = repo_path('results/work/CamCan/individualizedParcellation');
indiParcPath = fullfile(rootPath,'TY');
outPath = fullfile(rootPath,'ParcelSize');
if ~exist(outPath,'dir'); mkdir(outPath); end
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
regionNum = 48;

for i = 1:length(nets)
    tic
    currNetPath = fullfile(indiParcPath,nets{i},'indiParcellation');
    sub = dir(currNetPath);
    sub(1:2) = [];
    ParcelSize = zeros(regionNum,length(sub));
    for j = 1:length(sub)
        load(fullfile(currNetPath,sub(j).name));
        for k = 1:regionNum
            ParcelSize(k,j) = length(find(indiParcellation==k));
        end
        fprintf('%s sub %d finished\n',nets{i},j);
        toc
    end
    save(fullfile(outPath,[nets{i},'.mat']),'ParcelSize');
end

%% 
clear
subInformation = readtable(repo_path('data/resources/CamCan/subInfo.csv'));
load(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),'sFiles','trainSFiles');
testSFiles = setdiff(sFiles,trainSFiles);

subID = subInformation.Sub_ID;
% subID = num2str(subID);
% subID = [repmat('sub-0',size(subID,1),1),subID,repmat('.mat',size(subID,1),1)];
% subID = string(subID);
% subID = mat2cell(subID,431,1);
testSFiles = cell2mat(testSFiles);
testSFiles = testSFiles(:,1:end-4);
% testSFiles = str2num(testSFiles);
testInd = find(ismember(subID,testSFiles));
testSubInformation=subInformation(testInd,:);
save(fullfile(repo_path('results/work/CamCan/individualizedParcellation/testInformation.mat')));
