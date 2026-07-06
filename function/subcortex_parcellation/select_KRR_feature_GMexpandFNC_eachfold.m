function [Net_selected_feature,GM_selected_feature,Net_selected_ind,GM_selected_ind,best_match] = select_KRR_feature_GMexpandFNC_eachfold(all_atlas_FCN,y,cov_X)
alpha = 0.01;
nucleus_ind = {[1:4],[5:8],[9:14],[15:24],[25:30],[31:42],[43:48]};%2,2,3,5,3,6,3
% 标准化
for i = 1:size(all_atlas_FCN,1)
    a = squeeze(all_atlas_FCN(i,:,:,:));
    a = reshape(a,numel(a(:,:,1)),size(a,3));
    a = zscore(a);
    a = reshape(a,size(squeeze(all_atlas_FCN(i,:,:,:))));
    all_atlas_FCN(i,:,:,:) = a;
end
Net_based_FCN = all_atlas_FCN(2:8,:,:,:);
Net_based_FCN = reshape(Net_based_FCN,numel(Net_based_FCN(:,:,:,1)),size(Net_based_FCN,4));
GM_based_FCN = all_atlas_FCN(1,:,:,:);
GM_based_FCN = reshape(GM_based_FCN,numel(GM_based_FCN(:,:,:,1)),size(GM_based_FCN,4));

%% 筛选
% 筛选GM图谱的特征
[~,p] = partialcorr(GM_based_FCN',y,cov_X);
h = p<alpha;
GM_selected_p = p.*h;
GM_selected_ind = find(GM_selected_p);

% 筛选Net图谱的特征
[Net_selected_p,~,best_match] = select_feature_Net_corr_p(Net_based_FCN,y,cov_X,nucleus_ind,alpha);
Net_selected_ind = find(Net_selected_p);



GM_selected_feature = GM_based_FCN(GM_selected_ind,:);
Net_selected_feature = Net_based_FCN(Net_selected_ind,:);
end