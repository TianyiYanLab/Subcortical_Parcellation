% Purpose: all nets prediction pfm.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: save(fullfile(currTPath,'All nets PFM nuc by net.mat'),'MatNucByNet','posMatNucByNet','negMatNucByNet');; writetable(MatNucByNetMeanT,fullfile(currTPath,'All nets nucbynet mean mat.csv'),'WriteRowNames',true);
% Dependencies: CBIG_TRBPC_compute_singleKRR_PFM_lrx
%% compute all PFM
clear
root = repo_path('results/prediction/cognition');
PfmPath = fullfile(root,'Weights','results');
if ~exist(PfmPath,'dir'); mkdir(PfmPath); end
cogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};
replications = 100;
nucleusInd = {[1,2,26,27],[3,4,28,29],[5,6,7,30,31,32],[8:12,33:37],...
    [13:14,38:39],[15:20,40:45],[21:25,46:50]};
scoreInd = [1,1,1,1,1,1]; % EER metric changed from HappyAcc to TotalAcc
for ti = 1:length(cogTasks)
    currTaskPfm = zeros(50*7,replications);
    MatNucByNet = zeros(7,7,replications);
    posMatNucByNet = zeros(7,7,replications);
    negMatNucByNet = zeros(7,7,replications);
    for rep = 1:replications
        tic
        singleKRR_dir = fullfile(root,'prediction',cogTasks{ti},num2str(rep-1));
        currPfmAllFolds = CBIG_TRBPC_compute_singleKRR_PFM_lrx(singleKRR_dir, scoreInd(ti));
        % Average weights across all folds
        PFM_all_folds_mean = mean(currPfmAllFolds,2);
        currTaskPfm(:,rep) = PFM_all_folds_mean;
        % Extract positive and negative weights separately
        posPfm = PFM_all_folds_mean.*(PFM_all_folds_mean>0);
        negPfm = PFM_all_folds_mean.*(PFM_all_folds_mean<0);
        % Reshape weight vector into #nuclei by #net matrix
        PfmMat = reshape(PFM_all_folds_mean,50,7);
        posPfmMat = reshape(posPfm,50,7);
        negPfmMat = reshape(negPfm,50,7);
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
    currTPath = fullfile(PfmPath,cogTasks{ti});
    if ~exist(currTPath)
        mkdir(currTPath);
    end
    save(fullfile(currTPath,'All nets PFM nuc by net.mat'),'MatNucByNet','posMatNucByNet','negMatNucByNet');
    MatNucByNetMean = mean(MatNucByNet,3);
    posMatNucByNetMean = mean(posMatNucByNet,3);
    negMatNucByNetMean = mean(negMatNucByNet,3);

    nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
    nucleusNames = {'ACC','AMY','CAU','HIP','GP','PUT','THA'};

    % all, pos, neg
    MatNucByNetMeanT = array2table(MatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
    writetable(MatNucByNetMeanT,fullfile(currTPath,'All nets nucbynet mean mat.csv'),'WriteRowNames',true);
    posMatNucByNetMeanT = array2table(posMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
    writetable(posMatNucByNetMeanT,fullfile(currTPath,'All nets nucbynet pos mean mat.csv'),'WriteRowNames',true);
    negMatNucByNetMeanT = array2table(negMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
    writetable(negMatNucByNetMeanT,fullfile(currTPath,'All nets nucbynet neg mean mat.csv'),'WriteRowNames',true);
    % Raw results: #roi by #replications matrix written to table
    currNetPfmT = array2table(currTaskPfm);
    writetable(currNetPfmT,fullfile(currTPath,'All nets weights.csv'));
end
