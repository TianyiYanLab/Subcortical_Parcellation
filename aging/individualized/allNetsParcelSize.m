%%
clear
rootPath = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation';
indiParcPath = fullfile(rootPath,'Results');
outPath = fullfile(rootPath,'ParcelSize');
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
regionNum = 48;

for i = 2:length(nets)
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
subInformation = readtable('D:\research\HCP_parcellation_Lsym-AVR\CamCan\subInfo.csv');
load('D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\trainingSet.mat','sFiles','trainSFiles');
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
save(fullfile('D:\research\HCP_parcellation_Lsym-AVR\CamCan\individualizedParcellation\testInformation.mat'));