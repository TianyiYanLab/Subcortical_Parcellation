clear
root = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to age\metric=predictiveCOD';
OriginalPath = 'D:\research\HCP_parcellation_Lsym-AVR\CamCan\KRR parcel size to age\prediction';
iterations = 100;
nets = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN','All nets'};

for n = 1:length(nets)
    for j = 1:iterations
        param = load(fullfile(OriginalPath,num2str(j-1),nets{n},'setup.mat'));
        %param.outdir
        outdir = fullfile(root,'prediction',num2str(j-1),nets{n});
        if ~exist(outdir)
            mkdir(outdir);
        end
        param.outdir = outdir;

        %param.lambda_set
        param.lambda_set = [0.00001 0.0001 0.001 0.004 0.007 0.01 0.04 0.07 0.1 0.4 0.7 1 1.5 2 2.5 3 3.5 4 5 10 15 20];

        %param.metric
        param.metric = 'predictive_COD';

        param_name = strcat(outdir,'\setup.mat');
        save (param_name, '-struct', 'param');

        fprintf('Task = %s,iterations = %d\n',nets{n},j-1);
    end
end
for n = 1:length(nets)
    for j = 1:iterations
        path = fullfile(root,'prediction',num2str(j-1),nets{n},'setup.mat');
        CBIG_KRR_workflow(path);
    end
end