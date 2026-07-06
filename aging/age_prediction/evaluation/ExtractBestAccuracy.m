%MATLAB cbig
clear;
PredictionPath = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to age\metric=predictiveCOD\prediction';
nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN','GM','All nets'};
replications = 100;
num_folds=5;
result_all=zeros(replications,length(nets));
for i = 0:replications-1
    tic
    str1 = fullfile(PredictionPath,num2str(i));
    for j = 1:length(nets)
        net = nets{j};
        load(fullfile(PredictionPath,num2str(i),net,'setup.mat'),'sub_fold');%Extract the subject indices for each folded test set
        load([str1,'\',net,'\','final_result.mat'],'y_predict_concat');
        y_org_res=zeros(size(y_predict_concat,1),1);
    
        for kfold=1:num_folds % Extract residuals of each fold's test set participants based on the index
             load([str1,'\',net,'\y\fold_',num2str(kfold),'\y_regress.mat'],'y_resid');
             aa=find(sub_fold(kfold,1).fold_index==1);
             y_org_res(aa,1)=y_resid(aa,1);
        end
        save(fullfile(str1,net,'yOrgAndPredConcat.mat'),'y_org_res','y_predict_concat');
        result_corr=corr(y_org_res,y_predict_concat);
        result_all(i+1,j)=result_corr;
    end
    toc
    fprintf('rep %d, %s finished\n',i+1,net)
end
