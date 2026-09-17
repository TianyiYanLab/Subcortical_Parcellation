% Purpose: summarize acc.
% Input: result = load(fullfile(root,'prediction',num2str(j-1),currNet,'final_result.mat'));
% Output: writetable(T,fullfile(root,'evaluation',"Pearson's r.csv"));; writetable(TMae,fullfile(root,'evaluation',"MAE.csv"));
% Dependencies: MATLAB R2019b; see README.md.
%% extract result
clear
root = repo_path('results/prediction/age');
if ~exist(fullfile(root,'evaluation'),'dir'); mkdir(fullfile(root,'evaluation')); end
nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN','GM','All nets'};
NetsName = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN','GM','All_nets'};
iterations = 100;

all_acc = zeros(iterations,length(nets));
allMae = zeros(iterations,length(nets));
allRmse= zeros(iterations,length(nets));
allR2 = zeros(iterations,length(nets));
for i = 1:length(nets)
    currNet = nets{i};
    for j = 1:iterations
        result = load(fullfile(root,'prediction',num2str(j-1),currNet,'final_result.mat'));
        all_acc(j,i) = mean(result.optimal_acc,1);
        allMae(j,i) = mean(result.optimal_stats.MAE,1);
        allRmse(j,i) = mean(sqrt(result.optimal_stats.MSE),1);
        allR2(j,i) = mean(result.optimal_stats.COD,1);
    end
end
T = array2table(all_acc,'VariableNames',NetsName);
writetable(T,fullfile(root,'evaluation',"Pearson's r.csv"));
TMae = array2table(allMae,'VariableNames',NetsName);
writetable(TMae,fullfile(root,'evaluation',"MAE.csv"));
TRmse = array2table(allRmse,'VariableNames',NetsName);
writetable(TRmse,fullfile(root,'evaluation',"RMSE.csv"));
TR2 = array2table(allR2,'VariableNames',NetsName);
writetable(TR2,fullfile(root,'evaluation',"R2.csv"));
