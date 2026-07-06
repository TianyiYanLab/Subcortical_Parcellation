clear
cd('D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to cognition');
replication = 100;
% cogTasks = {'Fluid intelligence','Emotion expression recognition','TOT',...
%     'Face recognition','Hotel','Proverb','Force matching','Motor learning'};
cogTasks = {'VSTM','PicturePriming','RTchoice','RTsimple','FamousFaces',...
    'EmotionRegulation'};
for ti = 1:length(cogTasks)
    example = readtable(fullfile('data input',[cogTasks{ti},'.csv']));
    for rep = 0:replication-1
        load(fullfile('prediction',cogTasks{ti},num2str(rep),'splits.mat'));
        fold_index = cell(size(splits,1),1);
        subject_list = cell(size(splits,1),1);
        for fold = 1:size(splits,1)
            fold_index{fold} = zeros(size(example,1),1);
            fold_index{fold}(splits{fold,2}+1) = 1;
            fold_index{fold} = logical(fold_index{fold});
            subject_list{fold} = example.CCID(splits{fold,2}+1);
        end
        sub_fold = struct('subject_list', subject_list, 'fold_index', fold_index);
        save(fullfile('prediction',cogTasks{ti},num2str(rep),'StratifiedKfolds.mat'),'sub_fold');
    end
    fprintf('Task: %s finished\n',cogTasks{ti})
end