clear
root = '/path/to/your/data\CamCan\KRR parcel size to age';
iterations = 100;
N_perms = 1000;
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN','All nets'};
AllInputRepCorrMean = zeros(length(nets),N_perms);
for n = 1:length(nets)
    AllRepCorr = zeros(iterations,N_perms);
    for i = 0:iterations-1
        tic
        load(fullfile(root,'model perm test\all prediction results',num2str(i),nets{n},'acc_allFolds_permStart42.mat'))
        CurrCorr = mean(stats_perm.corr);
        AllRepCorr(i+1,:) = CurrCorr;
        fprintf('it:%d,net:%d finished\n',i,n)
        toc
    end
    AllInputRepCorrMean(n,:) = mean(AllRepCorr);
end
