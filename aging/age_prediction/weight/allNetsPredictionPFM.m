%% compute all PFM
clear

root = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to age\metric=predictiveCOD';
PfmPath = fullfile(root,'Weights');

net = 'All nets';

replications = 100;
nucleusInd = {[1,2,25,26],[3,4,27,28],[5,6,7,29,30,31],[8,9,10,11,12,32,33,34,35,36],...
    [13,14,15,37,38,39],[16:21,40:45],[22:24,46:48]};

currNetPfm = zeros(48*7,replications);
MatNucByNet = zeros(7,7,replications);
posMatNucByNet = zeros(7,7,replications);
negMatNucByNet = zeros(7,7,replications);
for rep = 1:replications
    tic
    singleKRR_dir = fullfile(root,'prediction',num2str(rep-1),net);
    score_ind = 1;
    currPfmAllFolds = CBIG_TRBPC_compute_singleKRR_PFM_lrx(singleKRR_dir, score_ind);
    %所有折权重平均
    PFM_all_folds_mean = mean(currPfmAllFolds,2);
    currNetPfm(:,rep) = PFM_all_folds_mean;
    %分别提取正负权重
    posPfm = PFM_all_folds_mean.*(PFM_all_folds_mean>0);
    negPfm = PFM_all_folds_mean.*(PFM_all_folds_mean<0);
    %将权重向量重组为#nuclei by #net 矩阵
    PfmMat = reshape(PFM_all_folds_mean,48,7);
    posPfmMat = reshape(posPfm,48,7);
    negPfmMat = reshape(negPfm,48,7);
    currMean = zeros(7,7);
    currPosMean = zeros(7,7);
    currNegMean = zeros(7,7);
    for nuclei = 1:length(nucleusInd)
        currMean(nuclei,:) = mean(PfmMat(nucleusInd{nuclei},:));
        currPosMean(nuclei,:) = mean(posPfmMat(nucleusInd{nuclei},:));
        currNegMean(nuclei,:) = mean(negPfmMat(nucleusInd{nuclei},:));
    end
    MatNucByNet(:,:,rep) = currMean;
    posMatNucByNet(:,:,rep) = currPosMean;
    negMatNucByNet(:,:,rep) = currNegMean;
    toc
    fprintf('rep %d finished\n',rep);
end
save(fullfile(PfmPath,'All nets PFM nuc by net.mat'),'MatNucByNet','posMatNucByNet','negMatNucByNet');
MatNucByNetMean = mean(MatNucByNet,3);
posMatNucByNetMean = mean(posMatNucByNet,3);
negMatNucByNetMean = mean(negMatNucByNet,3);

nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
nucleusNames = {'ACC','AMY','CAU','HIP','GP','PUT','THA'};
% all,pos,neg
MatNucByNetMeanT = array2table(MatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(MatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet mean mat.csv'),'WriteRowNames',true);
posMatNucByNetMeanT = array2table(posMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(posMatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet pos mean mat.csv'),'WriteRowNames',true);
negMatNucByNetMeanT = array2table(negMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(negMatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet neg mean mat.csv'),'WriteRowNames',true);
% 原始结果：#roi by #replications 矩阵写入表
currNetPfmT = array2table(currNetPfm);
writetable(currNetPfmT,fullfile(PfmPath,'All nets weights.csv'));