%% random group reproducibility
clear
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
individual_consensus_mat_inone_path = 'D:\research\HCP_FCS\subcortex_noPCA_FCS_compressed_inone';
load('D:\research\HCP_FCS\perm_list.mat');
out_path_sym = 'D:\research\HCP_parcellation_Lsym-AVR\HCP\All nets reproducibility\100 iterations group parcellation';
k_list = [2,2,3,5,3,6,3];
nets = {'VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
for i = 1:7
    fprintf('loading FCS_mat_inone\n')
    load(fullfile(individual_consensus_mat_inone_path,[nucleus{i},'.mat']));
    fprintf('FCS_mat_inone loaded\n')
    for n = 1:length(nets)
        tic
        curr_consensus_mat_L = all_sub_FCS{1,n+1};
        curr_consensus_mat_R = all_sub_FCS{2,n+1};
        group1_L_parcellation = zeros(round(sqrt(size(curr_consensus_mat_L,1)*2))+1,100);
        group1_R_parcellation = zeros(round(sqrt(size(curr_consensus_mat_R,1)*2))+1,100);
        group2_L_parcellation = zeros(round(sqrt(size(curr_consensus_mat_L,1)*2))+1,100);
        group2_R_parcellation = zeros(round(sqrt(size(curr_consensus_mat_R,1)*2))+1,100);
        for p = 1:size(perm_list,1)
            group1_L = curr_consensus_mat_L(:,perm_list{p,1});
            group1_R = curr_consensus_mat_R(:,perm_list{p,1});
            group2_L = curr_consensus_mat_L(:,perm_list{p,2});
            group2_R = curr_consensus_mat_R(:,perm_list{p,2});
            group1_L = mean(group1_L,2);
            group1_R = mean(group1_R,2);
            group2_L = mean(group2_L,2);
            group2_R = mean(group2_R,2);
            group1_L = group1_L.*(group1_L>0);
            group1_R = group1_R.*(group1_R>0);
            group2_L = group2_L.*(group2_L>0);
            group2_R = group2_R.*(group2_R>0);
            % reconstruct group adjacency mat
            group1_L = recon_symmat(group1_L);
            group1_L = group1_L+eye(size(group1_L));
            group1_R = recon_symmat(group1_R);
            group1_R = group1_R+eye(size(group1_R));
            group2_L = recon_symmat(group2_L);
            group2_L = group2_L+eye(size(group2_L));
            group2_R = recon_symmat(group2_R);
            group2_R = group2_R+eye(size(group2_R));

            %Lsym parcellation
            group1_L_parcellation(:,p) = SpectralClustering_Larry(group1_L,k_list(i),3);
            group1_R_parcellation(:,p) = SpectralClustering_Larry(group1_R,k_list(i),3);
            group2_L_parcellation(:,p) = SpectralClustering_Larry(group2_L,k_list(i),3);
            group2_R_parcellation(:,p) = SpectralClustering_Larry(group2_R,k_list(i),3);

            fprintf('%s %s perm %d finished\n',nets{n},nucleus{i},p)
        end
        group_parcellation_out_sym = fullfile(out_path_sym,nets{n});
        if ~exist(group_parcellation_out_sym);mkdir(group_parcellation_out_sym);end
        save(fullfile(group_parcellation_out_sym,[nucleus{i},'.mat']),'group1_L_parcellation','group1_R_parcellation','group2_L_parcellation','group2_R_parcellation');
        toc
    end
end
