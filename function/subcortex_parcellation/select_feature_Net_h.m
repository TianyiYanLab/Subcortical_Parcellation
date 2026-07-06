function selected_h = select_feature_Net_h(Net_eff_FCN,Net_ineff_FCN,nucleus_ind,alpha)
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
    selected_h = h_net_nucleus;
end
