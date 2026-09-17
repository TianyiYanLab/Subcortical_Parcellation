% Purpose: gen kfold.
% Input: example = readtable(fullfile('data input','GM.csv'));; load(fullfile('prediction',num2str(rep),'splits.mat'));
% Output: save(fullfile('prediction',num2str(rep),'StratifiedKfolds.mat'),'sub_fold');
% Dependencies: MATLAB R2019b; see README.md.
clear
cd(repo_path('results/prediction/age'));
replication = 100;
example = readtable(fullfile('data input','GM.csv'));
for rep = 0:replication-1
    load(fullfile('prediction',num2str(rep),'splits.mat'));
    fold_index = cell(size(splits,1),1);
    subject_list = cell(size(splits,1),1);
    for fold = 1:size(splits,1)
        fold_index{fold} = zeros(size(example,1),1);
        fold_index{fold}(splits{fold,2}+1) = 1;
        fold_index{fold} = logical(fold_index{fold});
        subject_list{fold} = example.Sub_ID(splits{fold,2}+1);
    end
    sub_fold = struct('subject_list', subject_list, 'fold_index', fold_index);
    save(fullfile('prediction',num2str(rep),'StratifiedKfolds.mat'),'sub_fold');
end
