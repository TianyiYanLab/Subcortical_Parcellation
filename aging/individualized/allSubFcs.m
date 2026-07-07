%% Whole nucleus similarity
clear
TS_path = '/path/to/your/data\Data\camcan\new_filter_Regress\fp_filter_regress';
sub = dir(fullfile(TS_path,'*.gz'));
FCS_path = '/path/to/your/data\CamCan\individualized Parcellation\FCS';
GM_mask = niftiread('/path/to/your/data\rGM_cortex_subcortex.nii');
GM_mask(isnan(GM_mask))=0;
GM_mask(GM_mask~=0)=1;
sub_mask = niftiread('/path/to/your/data\CamCan\individualized Parcellation\rGM_subcortex.nii');
sub_mask(isnan(sub_mask))=0;
sub_mask(sub_mask~=0)=1;

allZeroSub = [];
nanSub = [];
for i = 2:length(sub)
    tic
    sub_ima=niftiread(fullfile(TS_path,sub(i).name));
%     sub_ima=niftiread(fullfile(TS_path,'sub-CC721434_filter_reg.nii.gz'));
    s = cal_fcs(sub_mask,GM_mask,sub_ima);
    if isempty(s)
        warning('Subject %d TS has all-zero points\n',i)
        allZeroSub = [allZeroSub;sub(i).name(1:12)];
        continue
    elseif sum(isnan(s),'all')
        warning('Subject %d FCS has NaN values\n',i)
        nanSub = [nanSub;sub(i).name(1:12)];
        continue
    else
        save(fullfile(FCS_path,[sub(i).name(1:12),'.mat']),'s');
    end
    fprintf('Subject %d completed\n',i);
    toc
end
save(fullfile('/path/to/your/data\CamCan\individualized Parcellation','troubleSub.mat'),'nanSub','allZeroSub')