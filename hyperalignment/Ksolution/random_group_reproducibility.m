%% random group reproducibility
clear
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
FCS_path = 'F:\hyperalignment\forward_results';
load('E:\hyperalignment\perm_list.mat');
out_path = 'E:\hyperalignment\Ksolution\random group reproducibility';
subList = dir(FCS_path);
subList(1:2,:) = [];
max_k = 10;
for indNucleus = 6:7
    tic
    all_sub_FCS = cell(2,1);
    fprintf('loading FCS_mat\n')
    for indSub = 1:length(subList)
        load(fullfile(FCS_path,subList(indSub).name,[nucleus{indNucleus},'.mat']));
        all_sub_FCS{1,1} = [all_sub_FCS{1,1},FCS{1,1}];
        all_sub_FCS{2,1} = [all_sub_FCS{2,1},FCS{2,1}];
    end
%     load(fullfile(individual_consensus_mat_inone_path,[nucleus{indNucleus},'.mat']));
    fprintf('all FCS mat loaded\n')
    repro_sym = zeros(100,9);
    curr_consensus_mat_L = all_sub_FCS{1,1};
    curr_consensus_mat_R = all_sub_FCS{2,1};
    for indPerm = 1:size(perm_list,1)
        if exist(fullfile(out_path,'100iterations group parcellation',nucleus{indNucleus},['it_',num2str(indPerm),'.mat']))
            fprintf('perm %d finished, loading parcellation file.\n',indPerm)
            load(fullfile(out_path,'100iterations group parcellation',nucleus{indNucleus},['it_',num2str(indPerm),'.mat']))
        else
            group1_L = curr_consensus_mat_L(:,perm_list{indPerm,1});
            group1_R = curr_consensus_mat_R(:,perm_list{indPerm,1});
            group2_L = curr_consensus_mat_L(:,perm_list{indPerm,2});
            group2_R = curr_consensus_mat_R(:,perm_list{indPerm,2});
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
            group1_L_parcellation_sym = SpectralClustering_multiK_Larry(group1_L,max_k,3);
            group1_R_parcellation_sym = SpectralClustering_multiK_Larry(group1_R,max_k,3);
            group2_L_parcellation_sym = SpectralClustering_multiK_Larry(group2_L,max_k,3);
            group2_R_parcellation_sym = SpectralClustering_multiK_Larry(group2_R,max_k,3);

            group_parcellation_out_sym = fullfile(out_path,'100iterations group parcellation',nucleus{indNucleus});
            if ~exist(group_parcellation_out_sym);mkdir(group_parcellation_out_sym);end
            save(fullfile(group_parcellation_out_sym,['it_',num2str(indPerm),'.mat']),'group1_L_parcellation_sym','group1_R_parcellation_sym','group2_L_parcellation_sym','group2_R_parcellation_sym');
        end
        
        for indK = 1:9
            group1_parcellation = [group1_L_parcellation_sym(:,indK);group1_R_parcellation_sym(:,indK)+max(group1_L_parcellation_sym(:,indK))];
            group2_parcellation = [group2_L_parcellation_sym(:,indK);group2_R_parcellation_sym(:,indK)+max(group2_L_parcellation_sym(:,indK))];
            repro_sym(indPerm,indK) = iteration_Dice_munkres(group1_parcellation,group2_parcellation);
        end
        fprintf('nuc%d it%d finished\n',indNucleus,indPerm)
        toc
    end
    save(fullfile(out_path,[nucleus{indNucleus},'_random_group_reproducibility.mat']),'repro_sym');
end
%% 
% nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
% repro = [repro_L_sym;repro_R_sym];
% repro = [repro_L_rw;repro_R_rw];
