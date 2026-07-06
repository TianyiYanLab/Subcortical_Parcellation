function [selected_p,selected_h,best_match] = select_feature_Net_p(Net_eff_FCN,Net_ineff_FCN,nucleus_ind,alpha)
    nucleus_num = length(nucleus_ind);
    parcel_num = max(cellfun(@max,nucleus_ind));

    [h,p] = ttest2(Net_eff_FCN',Net_ineff_FCN','Alpha',alpha);
    h = reshape(h',nucleus_num,parcel_num,400);
    p = reshape(p',nucleus_num,parcel_num,400);
    hp = p.*h;

    comparation_h = sum(h,3);
    for i = 1:nucleus_num
        h_net_nucleus(:,i) = sum(comparation_h(:,nucleus_ind{i}),2);
    end
    comparation_hp = sum(hp,3);
    for i = 1:nucleus_num
        hp_net_nucleus(:,i) = sum(comparation_hp(:,nucleus_ind{i}),2);
    end
    comparation = hp_net_nucleus./h_net_nucleus;

    for i = 1:nucleus_num
        s = h_net_nucleus(:,i);
        best_match{i} = find(s==max(s));
    end
    
    for i = 1:nucleus_num
        if length(best_match{i})~=1
            best_match{i} = find(comparation(:,i)==min(comparation(best_match{i},i)));
        end
    end

    selected_h = zeros(nucleus_num,parcel_num,400);
    for i = 1:nucleus_num
        selected_h(best_match{i},nucleus_ind{i},:) = h(best_match{i},nucleus_ind{i},:);
    end
    selected_p = p.*selected_h;
end
