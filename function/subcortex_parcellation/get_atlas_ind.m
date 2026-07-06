function ind = get_atlas_ind(atlas_file,msk_file)
    [~,atlas] = read(atlas_file);
    [~,msk] = read(msk_file);
    msk(~~msk)=1;
    msk_ind = find(msk);
    ind = cell(length(unique(atlas))-1,1);
    for i = 1:length(ind)
        curr_parcel_ind = find(atlas==i);
        curr_parcel_in_msk_ind = find(ismember(msk_ind,curr_parcel_ind));
        ind{i} = curr_parcel_in_msk_ind;
    end