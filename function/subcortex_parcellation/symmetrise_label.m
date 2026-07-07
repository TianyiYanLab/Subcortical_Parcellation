function relabeled_R = symmetrise_label(L,R)
% L: Left brain NIfTI matrix
% R: Right brain NIfTI matrix
    Lsym = zeros(size(L));
    ind_L = find(L~=0);
    label_L = L(ind_L);
    [coord_L(:,1),coord_L(:,2),coord_L(:,3)] = ind2sub([size(L)],ind_L);
    coord_Lsym = coord_L;
    coord_Lsym(:,1) = size(L,1)+1-coord_Lsym(:,1);
    ind_Lsym = sub2ind([size(L)],coord_Lsym(:,1),coord_Lsym(:,2),coord_Lsym(:,3));
    Lsym(ind_Lsym) = label_L;
    % mat2nii(Lsym,'Lsym.nii',size(Lsym),32,'D:\Data\research\GP_parcellation\mask\GP_Mask\GP_rightmask.nii');

    for i = 1:length(unique(R))-1
        ind_R = find(R==i);
        for j = 1:length(unique(Lsym))-1
            ind_Lsym = find(Lsym==j);
            nij(i,j) = 2*length(intersect(ind_R,ind_Lsym))/(length(find(ind_R))+length(find(ind_Lsym)));
        end
    end
    [~,I] = max(nij,[],2);
    clusters_ind = cell(1,length(unique(R))-1);
    for i = 1:length(unique(R))-1
        clusters_ind{i} = find(R==i);
    end
    for i = 1:length(unique(R))-1
        R(clusters_ind{i})=I(i);
    end
    relabeled_R = R;
end