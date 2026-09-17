% Purpose: pfm.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: writetable(currNetPfmTable,fullfile(PfmPath,[nets{net},'.csv']));; writetable(currNetPfmMeanAcrossNucleusTable,fullfile(PfmPath,[nets{net},' mean.csv']));
% Dependencies: CBIG_TRBPC_compute_singleKRR_PFM_lrx
%% compute all PFM
clear
root = repo_path('results/prediction/age');
nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
replications = 100;
PfmPath = fullfile(root,'Weights');
nucleusInd = {[1,2,26,27],[3,4,28,29],[5,6,7,30,31,32],[8:12,33:37],...
    [13:14,38:39],[15:20,40:45],[21:25,46:50]};
nucleusNames = {'ACC','AMY','CAU','HIP','GP','PUT','THA'};

for net = 1:length(nets)
    currNetPfm = zeros(50,replications);
    currNetPfmMeanAcrossNucleus = zeros(7,replications);
    currNetPfmPosMeanAcrossNucleus = zeros(7,replications);
    currNetPfmNegMeanAcrossNucleus = zeros(7,replications);
    for rep = 1:replications
        tic
        singleKRR_dir = fullfile(root,'prediction',num2str(rep-1),nets{net});
        score_ind = 1;
        currPfmAllFolds = CBIG_TRBPC_compute_singleKRR_PFM_lrx(singleKRR_dir, score_ind);

        PFM_all_folds_mean = mean(currPfmAllFolds,2);
        currNetPfm(:,rep) = PFM_all_folds_mean;
        posPfm = PFM_all_folds_mean.*(PFM_all_folds_mean>0);
        negPfm = PFM_all_folds_mean.*(PFM_all_folds_mean<0);
        for nuclei = 1:length(nucleusInd)
            currMean = mean(PFM_all_folds_mean(nucleusInd{nuclei}));
            currPosMean = mean(posPfm(nucleusInd{nuclei}));
            currNegMean = mean(negPfm(nucleusInd{nuclei}));
            currNetPfmMeanAcrossNucleus(nuclei,rep) = currMean;
            currNetPfmPosMeanAcrossNucleus(nuclei,rep) = currPosMean;
            currNetPfmNegMeanAcrossNucleus(nuclei,rep) = currNegMean;
        end
        toc
        fprintf('rep %d net %s finished\n',rep,nets{net});
    end
    currNetPfmTable = array2table(currNetPfm');
    writetable(currNetPfmTable,fullfile(PfmPath,[nets{net},'.csv']));
    currNetPfmMeanAcrossNucleusTable = array2table(currNetPfmMeanAcrossNucleus','VariableNames',nucleusNames);
    writetable(currNetPfmMeanAcrossNucleusTable,fullfile(PfmPath,[nets{net},' mean.csv']));
    currNetPfmPosMeanAcrossNucleusTable = array2table(currNetPfmPosMeanAcrossNucleus','VariableNames',nucleusNames);
    writetable(currNetPfmPosMeanAcrossNucleusTable,fullfile(PfmPath,[nets{net},' pos mean.csv']));
    currNetPfmNegMeanAcrossNucleusTable = array2table(currNetPfmNegMeanAcrossNucleus','VariableNames',nucleusNames);
    writetable(currNetPfmNegMeanAcrossNucleusTable,fullfile(PfmPath,[nets{net},' neg mean.csv']));
end
