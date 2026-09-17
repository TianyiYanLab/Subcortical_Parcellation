% Purpose: run individualization.
% Input: [~,parc]=read(mskFile);; load(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),'trainSFiles');
% Output: save(fullfile(currOutPath,['dilated_',num2str(DilThresh),'_',nets{i},'_subcortex.mat']),'img_dil','ind');; save(fullfile(currOutPath,['region',num2str(reg),'_Dil',num2str(DilThresh),'_train.mat']),'Out','img_dil','ind','-v7.3');
% Dependencies: mat2nii, read, svm_test, svm_train
%% Check that subcortical masks for all networks are the same after resampling
% clear
% refTemp = niftiread(fullfile(root,'rGM_subcortex.nii'));
% refTemp(isnan(refTemp))=0;
% refMskInd = find(refTemp);
% 
% nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
% 
% for i = 1:length(nets)
%     currNetTemp = niftiread(fullfile(root,['r',nets{i},'_subcortex.nii']));
%     currNetTemp(isnan(currNetTemp))=0;
%     currNetInd = find(currNetTemp);
%     if ~isempty(find(refMskInd~=currNetInd))
%         warning('Net %d mask is not consistent with GM');
%     end
% end

%% Dilate parcellation
clear
groupParcellationPath = repo_path('results/work/CamCan/individualizedParcellation');
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};

for i = 1:length(nets)
    tic
    currOutPath = fullfile(groupParcellationPath,'TY',nets{i});
    if~exist(currOutPath);mkdir(currOutPath);end
    % Group parcellation
    mskFile=fullfile(groupParcellationPath,['r',nets{i},'_subcortex.nii']);
    [~,parc]=read(mskFile);
    parc(isnan(parc))=0;
    %Extent of dilation (integer value)
    DilThresh=1; %Dilate 1 voxels

    ind=find(parc);
    regs=unique(parc(ind));

    Nxyz=size(parc);  %image size
    N=length(regs);   %number of regions

    fprintf('Dilating each region...\n');
    se=strel('sphere',DilThresh);
    img_dil=cell(N,1);
    rdil=zeros(N,1);
    for j=1:N
        ind_reg=find(regs(j)==parc);
        img=zeros(Nxyz);
        img(ind_reg)=1;

        %0: not considered, 1: other regions, 2: region of interest
        img_dil{j}=imdilate(img,se).*~~parc+img;
        rdil(j)=sum(~~img_dil{j}(:))/sum(img(:));
    end
    save(fullfile(currOutPath,['dilated_',num2str(DilThresh),'_',nets{i},'_subcortex.mat']),'img_dil','ind');
    fprintf('Net %d finished\n',i)
    toc
end

%% Train SVM
clear
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
FCS_path = repo_path('results/work/CamCan/individualizedParcellation/FCS');
load(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),'trainSFiles');
for i = 1:length(trainSFiles)
    trainSFiles{i} = fullfile(FCS_path,trainSFiles{i});
end
resultPath = repo_path('results/work/CamCan/individualizedParcellation/TY');

for i = 1:length(nets)
    currInPath = fullfile(resultPath,nets{i});
    DilThresh = 1;
    J=length(trainSFiles);
    load(fullfile(currInPath,['dilated_',num2str(DilThresh),'_',nets{i},'_subcortex.mat']));
    currOutPath = fullfile(resultPath,nets{i},'trainedSVM');
    if~exist(currOutPath);mkdir(currOutPath);end
    for reg = 1:length(img_dil)
        % This part is time consuming
        tic
        fprintf('/n<strong>Region %d/n',reg)
        fprintf('Training SVM on (%d subjects)...\n',J);
        img_dil_reg=img_dil{reg};
        Out=svm_train(J,trainSFiles,img_dil_reg,ind);
        save(fullfile(currOutPath,['region',num2str(reg),'_Dil',num2str(DilThresh),'_train.mat']),'Out','img_dil','ind','-v7.3');
        toc
    end
    fprintf('Net %d finished\n',i)
end

%% Test SVM
clear
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
load(repo_path('results/work/CamCan/individualizedParcellation/trainingSet.mat'),'sFiles','trainSFiles');
testSFiles = setdiff(sFiles,trainSFiles);
clear sFiles trainSFiles
FCS_path = repo_path('results/work/CamCan/individualizedParcellation/FCS');
resultPath = repo_path('results/work/CamCan/individualizedParcellation/TY');

DilThresh = 1;
for i = 1:length(nets)
    currTrainedSVMPath = fullfile(resultPath,nets{i},'trainedSVM');
    currTestedSVMPath = fullfile(resultPath,nets{i},'testedSVM');
    load(fullfile(resultPath,nets{i},['dilated_',num2str(DilThresh),'_',nets{i},'_subcortex.mat']));
    for reg = 1:length(img_dil)
        load(fullfile(currTrainedSVMPath,['region',num2str(reg),'_Dil',num2str(DilThresh),'_train.mat']));
        for j = 1:length(testSFiles)
            currOutPath = fullfile(currTestedSVMPath,testSFiles{j}(1:end-4));
            if ~exist(currOutPath);mkdir(currOutPath);end
            load(fullfile(FCS_path,testSFiles{j}));
            % Compute the probabilistic map 
            img_dil_reg=img_dil{reg};
            [y_img,dice]=svm_test(img_dil_reg,Out,s,ind);
    %         mat2nii(y_img,fullfile(currOutPath,['region',num2str(reg),'_probmap.nii']),size(y_img),32,mskFile);
            save(fullfile(currOutPath,['region',num2str(reg),'_probmap.mat']),'y_img');
            fprintf('region %d,subject %d,Dice=%.2f\n',reg,j,dice)
        end
    end
end

%% Reconstruct individualized parcellation
clear
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
rootPath = repo_path('results/work/CamCan/individualizedParcellation');
thresh = 0;
for n = 1:length(nets)
probmapPath = fullfile(rootPath,'TY',nets{n},'testedSVM');
mskFile=fullfile(rootPath,['r',nets{n},'_subcortex.nii']);
dilMsk = niftiread(mskFile);
dilMsk(isnan(dilMsk))=0;
voxelInd = find(dilMsk);
outPath = fullfile(rootPath,'TY',nets{n},'indiParcellation');
if~exist(outPath);mkdir(outPath);end
sub = dir(probmapPath);
sub(1:2) = [];

for i = 1:length(sub)
    tic
    probmapAllRegion = zeros(length(voxelInd),48);
%     if exist(fullfile(outPath,[sub(i).name,'.mat']));continue;end
    for j = 1:48
        load(fullfile(probmapPath,sub(i).name,['region',num2str(j),'_probmap.mat']));
        currParcProb = y_img(voxelInd);
        probmapAllRegion(:,j) = currParcProb;
    end
    threshedProbmapAllRegion = probmapAllRegion.*(probmapAllRegion>=thresh);
    [~,indiParcellationLabel] = max(threshedProbmapAllRegion,[],2);
    indiParcellation = zeros(size(dilMsk));
    indiParcellation(voxelInd) = indiParcellationLabel;
%     mat2nii(indiParcellation,fullfile(out_path,[sub(i).name,'.nii']),size(indiParcellation),32,mskFile);
    save(fullfile(outPath,[sub(i).name,'.mat']),'indiParcellation');
    fprintf('nets %d sub %d finished\n',n,i)
    toc
end
end

