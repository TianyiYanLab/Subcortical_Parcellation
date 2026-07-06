function relabeled_parcellation = standardize_label(standard,parcellation)
    for i = 1:length(unique(parcellation))-1
        ind_R = find(parcellation==i);
        for j = 1:length(unique(standard))-1
            ind_Lsym = find(standard==j);
            nij(i,j) = 2*length(intersect(ind_R,ind_Lsym))/(length(find(ind_R))+length(find(ind_Lsym)));
        end
    end
    [~,I] = max(nij,[],2);
    clusters_ind = cell(1,length(unique(parcellation))-1);
    for i = 1:length(unique(parcellation))-1
        clusters_ind{i} = find(parcellation==i);
    end
    for i = 1:length(unique(parcellation))-1
        parcellation(clusters_ind{i})=I(i);
    end
    relabeled_parcellation = parcellation;
end