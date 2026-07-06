clear
root = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to age\metric=predictiveCOD';
iterations = 100;
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN','All nets'};

score_ind = 1;
perm_seed_start = 42;
N_perm = 1000;
metrics = {'corr'};

for i = 0:iterations-1
    for n = 1:length(nets)
        tic
        singleKRR_dir = fullfile(root,'prediction',num2str(i),nets{n});
        outdir = fullfile(root,'model perm test','all prediction results',num2str(i),nets{n});
        compute_singleKRR_perm_stats_lrx_AllAtlasAgePrediction(singleKRR_dir,...
            score_ind, perm_seed_start,N_perm, outdir,metrics)
        fprintf('it:%d,net:%d finished\n',i,n)
        toc
    end
end