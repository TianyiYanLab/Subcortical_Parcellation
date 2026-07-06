function [Net_selected_ind,GM_selected_ind,best_match] = select_KRR_feature_woFNC_eachfold_GMexpand(all_atlas_FCN,y,cov_X)
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
    [Net_selected_p,~,best_match,selected_atlas_p] = select_feature_Net_corr_p(Net_based_FCN,y,cov_X,nucleus_ind,alpha);
    Net_selected_ind = find(Net_selected_p);

    % 考虑Net特征数少于GM的情况
    if length(Net_selected_ind) < length(GM_selected_ind)
        GM_selected_p = GM_selected_p(GM_selected_ind);
        % 先从selected_atlas_p
        selected_atlas_p = reshape(selected_atlas_p,numel(selected_atlas_p),1);
        none_zero_selected_atlas_p_ind = find(selected_atlas_p~=0);
        none_zero_selected_atlas_p = selected_atlas_p(none_zero_selected_atlas_p_ind);
        
        [B,I] = mink(none_zero_selected_atlas_p,length(GM_selected_p));
        I = sort(I);
        
        New_net_p = zeros(size(none_zero_selected_atlas_p));
        New_net_p(I) = none_zero_selected_atlas_p(I);
        final_Net_selected_p = zeros(size(selected_atlas_p));
        final_Net_selected_p(none_zero_selected_atlas_p_ind) = New_net_p;
        Net_selected_ind = find(final_Net_selected_p);
        GM_selected_ind = [];
%         GM_selected_feature = [];
%         Net_selected_feature = Net_based_FCN(Net_selected_ind,:);
    else
        Net_selected_p = Net_selected_p(Net_selected_ind);
        [~,I] = mink(p,length(Net_selected_p));
        I = sort(I);
        GM_selected_ind = I;
        Net_selected_ind = [];
%         GM_selected_feature = GM_based_FCN(GM_selected_ind,:);
%         Net_selected_feature = [];
    end
end