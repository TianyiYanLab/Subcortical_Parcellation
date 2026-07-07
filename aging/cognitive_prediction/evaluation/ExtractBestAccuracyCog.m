%MATLAB cbig
clear;
PredictionPath = '/path/to/your/data\CamCan\KRR parcel size to cognition\metric=predictiveCOD\prediction';
CogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};
ScoreInd = [1,1,1,1,1,1];
replications = 100;
num_folds=5;
result_all=zeros(replications,length(CogTasks));
for j = 1:length(CogTasks)
    tic
    ct = CogTasks{j};
    si = ScoreInd(j);
    for i = 0:replications-1
        CurrRepPath = fullfile(PredictionPath,ct,num2str(i));
        load(fullfile(CurrRepPath,'setup.mat'),'sub_fold'); % Extract subject indices for each fold's test set
        load(fullfile(CurrRepPath,'final_result.mat'),'y_predict_concat');
        y_predict_concat = y_predict_concat(:,si);
        y_org_res=zeros(size(y_predict_concat,1),1);
    
        for kfold=1:num_folds % Extract residuals for each fold's test set based on indices
             load([CurrRepPath,'\y\fold_',num2str(kfold),'\y_regress.mat'],'y_resid');
             aa=find(sub_fold(kfold,1).fold_index==1);
             y_org_res(aa,1)=y_resid(aa,si);
        end
        save(fullfile(CurrRepPath,'yOrgAndPredConcat.mat'),'y_org_res','y_predict_concat');
        result_corr=corr(y_org_res,y_predict_concat);
        result_all(i+1,j)=result_corr;
        fprintf('rep %d, %s finished\n',i+1,ct)
    end
    toc
end