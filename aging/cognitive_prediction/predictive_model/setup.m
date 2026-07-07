clear
root = '/path/to/your/data\CamCan\KRR parcel size to cognition\metric=predictiveCOD';
OriginalPath = '/path/to/your/data\CamCan\KRR parcel size to cognition\prediction';
iterations = 100;
cogTasks = {'Fluid intelligence','Emotion expression recognition',...
    'PicturePriming','Face recognition','FamousFaces','Motor learning'};
ScoreInds = [1,7,1,1,1,2];
for ct = 1:length(cogTasks)
    for j = 1:iterations
        load(fullfile(OriginalPath,cogTasks{ct},num2str(j-1),'setup.mat'));
        %param.outdir
        outdir = fullfile(root,'prediction',cogTasks{ct},num2str(j-1));
        if ~exist(outdir)
            mkdir(outdir);
        end
        param.outdir = outdir;

        %param.sub_fold
        param.sub_fold = sub_fold;

        %param.y
        param.y = y(:,ScoreInds(ct));

        %param.covariates
        param.covariates = covariates;

        %param.feature_mat
        param.feature_mat = feature_mat;

        %param.num_inner_folds
        param.num_inner_folds = 5;

        %param.outstem
        param.outstem = [];

        %param.with_bias
        param.with_bias = 1;

        %param.ker_param
        param.ker_param.type = 'corr';
        param.ker_param.scale = NaN;

        %param.lambda_set
        param.lambda_set = [0.00001 0.0001 0.001 0.004 0.007 0.01 0.04 0.07 0.1 0.4 0.7 1 1.5 2 2.5 3 3.5 4 5 10 15 20];

        %param.metric
        param.metric = 'predictive_COD';

        param_name = strcat(outdir,'\setup.mat');
        save (param_name, '-struct', 'param');

        fprintf('Task = %s,iterations = %d\n',cogTasks{ct},j-1);
    end
end
for ct = 1:length(cogTasks)
    for j = 1:iterations
        path = fullfile(root,'prediction',cogTasks{ct},num2str(j-1),'setup.mat');
        CBIG_KRR_workflow(path);
    end
end