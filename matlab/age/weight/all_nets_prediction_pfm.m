% Purpose: all nets prediction pfm.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: save(fullfile(PfmPath,'All nets PFM nuc by net.mat'),'MatNucByNet','posMatNucByNet','negMatNucByNet');; writetable(MatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet mean mat.csv'),'WriteRowNames',true);
% Dependencies: CBIG_TRBPC_compute_singleKRR_PFM_lrx
%% compute all PFM
clear

root = repo_path('results/prediction/age');
PfmPath = fullfile(root,'Weights');
if ~exist(PfmPath,'dir'); mkdir(PfmPath); end

net = 'All nets';

replications = 100;
nucleusInd = {[1,2,26,27],[3,4,28,29],[5,6,7,30,31,32],[8:12,33:37],...
    [13:14,38:39],[15:20,40:45],[21:25,46:50]};

currNetPfm = zeros(50*7,replications);
MatNucByNet = zeros(7,7,replications);
posMatNucByNet = zeros(7,7,replications);
negMatNucByNet = zeros(7,7,replications);
for rep = 1:replications
    tic
    singleKRR_dir = fullfile(root,'prediction',num2str(rep-1),net);
    score_ind = 1;
    currPfmAllFolds = CBIG_TRBPC_compute_singleKRR_PFM_lrx(singleKRR_dir, score_ind);
    % Average weights across all folds
    PFM_all_folds_mean = mean(currPfmAllFolds,2);
    currNetPfm(:,rep) = PFM_all_folds_mean;
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
save(fullfile(PfmPath,'All nets PFM nuc by net.mat'),'MatNucByNet','posMatNucByNet','negMatNucByNet');
MatNucByNetMean = mean(MatNucByNet,3);
posMatNucByNetMean = mean(posMatNucByNet,3);
negMatNucByNetMean = mean(negMatNucByNet,3);

nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
nucleusNames = {'ACC','AMY','CAU','HIP','GP','PUT','THA'};
% all, pos, neg
MatNucByNetMeanT = array2table(MatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(MatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet mean mat.csv'),'WriteRowNames',true);
posMatNucByNetMeanT = array2table(posMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(posMatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet pos mean mat.csv'),'WriteRowNames',true);
negMatNucByNetMeanT = array2table(negMatNucByNetMean,'VariableNames',nets,'RowNames',nucleusNames);
writetable(negMatNucByNetMeanT,fullfile(PfmPath,'All nets nucbynet neg mean mat.csv'),'WriteRowNames',true);
% Raw results: #roi by #replications matrix written to table
currNetPfmT = array2table(currNetPfm);
writetable(currNetPfmT,fullfile(PfmPath,'All nets weights.csv'));
