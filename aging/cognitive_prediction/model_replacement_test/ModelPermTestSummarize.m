clear
root = '/path/to/your/data\CamCan\KRR parcel size to cognition';
iterations = 100;
N_perms = 1000;
cogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};
AllInputRepCorrMean = zeros(length(cogTasks),N_perms);
for n = 1:length(cogTasks)
    AllRepCorr = zeros(iterations,N_perms);
    for i = 0:iterations-1
        tic
        load(fullfile(root,'model perm test\all prediction results',cogTasks{n},num2str(i),'acc_allFolds_permStart42.mat'))
        CurrCorr = mean(stats_perm.corr);
        AllRepCorr(i+1,:) = CurrCorr;
        fprintf('it:%d,net:%d finished\n',i,n)
        toc
    end
    AllInputRepCorrMean(n,:) = mean(AllRepCorr);
end
