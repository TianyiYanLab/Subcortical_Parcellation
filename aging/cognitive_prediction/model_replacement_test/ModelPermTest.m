clear
root = '/path/to/your/data\CamCan\KRR parcel size to cognition\metric=predictiveCOD';
iterations = 100;
cogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};

ScoreInds = [1,1,1,1,1,1];
perm_seed_start = 42;
N_perm = 1000;
metrics = {'corr'};

for i = 0:iterations-1
    for n = 1:length(cogTasks)
        tic
        score_ind = ScoreInds(n);
        singleKRR_dir = fullfile(root,'prediction',cogTasks{n},num2str(i));
        outdir = fullfile(root,'model perm test','all prediction results',cogTasks{n},num2str(i));
        compute_singleKRR_perm_stats_lrx_AllAtlasAgePrediction(singleKRR_dir, score_ind, perm_seed_start,N_perm, outdir,metrics)
        fprintf('it:%d,net:%d finished\n',i,n)
        toc
    end
end