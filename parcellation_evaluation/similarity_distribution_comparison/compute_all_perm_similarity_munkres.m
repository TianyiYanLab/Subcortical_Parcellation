%% Compute similarity across all permutations
clear
load('D:\research\HCP_parcellation_Lsym-AVR\HCP\Robostic\perm_list');
relabeled_parcellation_path = 'D:\research\HCP_parcellation_Lsym-AVR\HCP\Robostic\relabeled_all_sub_parcellation';
out_dir = 'D:\research\HCP_parcellation_Lsym-AVR\HCP\Robostic\all_perm_similarity';
nucleus = {'SUBCORTEX'};

for j = 1:length(nucleus)
    load(fullfile(relabeled_parcellation_path,[nucleus{j},'.mat']));
    relabled_all_sub_parcellation = relabled_all_sub_parcellation(:,2:8,:);
    all_perm_similarity = zeros(7,7,1000);
    for i = 1:size(perm_list,1)
        group1 = perm_list{i,1};
        group2 = perm_list{i,2};

        group1_all_parcellation = relabled_all_sub_parcellation(:,:,group1);
        group1_parcellation = zeros(size(group1_all_parcellation,1),size(group1_all_parcellation,2));
        for k = 1:size(group1_all_parcellation,2)
            curr_net = squeeze(group1_all_parcellation(:,k,:));
            group1_parcellation(:,k) = mode(curr_net,2);
        end
        group2_all_parcellation = relabled_all_sub_parcellation(:,:,group2);
        group2_parcellation = zeros(size(group2_all_parcellation,1),size(group2_all_parcellation,2));
        for k = 1:size(group2_all_parcellation,2)
            curr_net = squeeze(group2_all_parcellation(:,k,:));
            group2_parcellation(:,k) = mode(curr_net,2);
        end

        similarity_matrix = zeros(7,7);
        for k = 1:size(similarity_matrix,1)
            for l = 1:size(similarity_matrix,2)
                similarity_matrix(k,l) = iteration_Dice_munkres(group1_parcellation(:,k),group2_parcellation(:,l));
            end
        end

        all_perm_similarity(:,:,i) = similarity_matrix;
        fprintf('Nucleus: %d/%d, progress: %d/%d\n',j,1,i,1000);
    end
    save(fullfile(out_dir,[nucleus{j},'.mat']),'all_perm_similarity');
end