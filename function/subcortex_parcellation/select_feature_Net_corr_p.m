function [selected_p,selected_h,best_match,selected_atlas_p] = select_feature_Net_corr_p(Net_based_FCN,y,cov_X,nucleus_ind,alpha)
    nucleus_num = length(nucleus_ind);
    parcel_num = max(cellfun(@max,nucleus_ind));

    [~,p] = partialcorr(Net_based_FCN',y,cov_X); % Partial correlation, regressing out covariates
    h = p<alpha;
    h = reshape(h',7,parcel_num,400);
    p = reshape(p',7,parcel_num,400);
    hp = p.*h; % Keep only significant p-values

    comparation_h = sum(h,3);
    h_net_nucleus = zeros(7,nucleus_num);
    for i = 1:7
        h_net_nucleus(:,i) = sum(comparation_h(:,nucleus_ind{i}),2);
    end
    
    comparation_hp = sum(hp,3); % Sum of significant p-values across 400 cortical parcels for each network and nucleus
    hp_net_nucleus = zeros(7,nucleus_num);
    for i = 1:7
        hp_net_nucleus(:,i) = sum(comparation_hp(:,nucleus_ind{i}),2);
    end
    comparation = hp_net_nucleus./h_net_nucleus;

    for i = 1:7
        s = h_net_nucleus(:,i);
        best_match{i} = find(s==max(s));
    end
    
    for i = 1:7
        if length(best_match{i})~=1
            best_match{i} = find(comparation(:,i)==min(comparation(best_match{i},i)));
        end
    end

    selected_h = zeros(7,parcel_num,400);
    for i = 1:7
        selected_h(best_match{i},nucleus_ind{i},:) = h(best_match{i},nucleus_ind{i},:);
    end
    selected_p = p.*selected_h;
    
    selected_atlas_p = zeros(7,parcel_num,400);
    for i = 1:7
        selected_atlas_p(best_match{i},nucleus_ind{i},:) = p(best_match{i},nucleus_ind{i},:);
    end
end