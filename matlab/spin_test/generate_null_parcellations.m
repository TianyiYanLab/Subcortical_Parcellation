% Purpose: generate null parcellations.
% Input: load(repo_path('data/derived/spin_permutations.mat'));; load(repo_path('data/templates/cortexIndex.mat'));
% Output: save(fullfile(out_path, [nucNames{n_nuc}, '.mat']), 'L_parcellation', 'R_parcellation');
% Dependencies: SpectralClustering_Larry, read 
%% non-parallel
clear
nucNames = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
FC_path = repo_path('results/hyperalignment/forward');

% Read the random partition and index info
load(repo_path('data/derived/spin_permutations.mat'));
load(repo_path('data/templates/cortexIndex.mat'));
load(repo_path('data/templates/nucStartsEnds.mat'));

parcellation_path = repo_path('results/spin_test/parcellations');

k_list = [2,2,3,5,2,6,5];
sub = dir(FC_path);
sub(1:2) = [];

% Number of permutations per large-matrix read (trade-off between memory and I/O speed)
block_size = 5; 

for block_start = 1:block_size:1000
    block_end = min(block_start + block_size - 1, 1000);
    
    % Find the incomplete permutations within this block
    perms_to_run = [];
    for p = block_start:block_end
        out_path = fullfile(parcellation_path, num2str(p));
        if ~is_perm_done(out_path, nucNames)
            perms_to_run = [perms_to_run, p];
        else
            fprintf('Loop %d has been completed, skipping\n', p);
        end
    end
    
    if isempty(perms_to_run)
        continue % This block has been fully processed. Move to the next block.
    end
    
    num_perms_run = length(perms_to_run);
    
    % Pre-extract the cortical label assignments for all perms in this block to save inner-loop time
    cortLabelL = zeros(num_perms_run, length(left_list));
    cortLabelR = zeros(num_perms_run, length(right_list));
    
    % [Performance optimization 3]: Before starting the subject loop, precompute the row-slice indices for all perm and all net combinations!
    % This completely eliminates the extremely time-consuming find() function and array concatenation in the inner loop.
    precomputed_cort_idx = cell(num_perms_run, 7);
    for pi = 1:num_perms_run
        p = perms_to_run(pi);
        currL = perm_l(p,:); 
        currR = perm_r(p,:);
        
        for n_net = 1:7
            ind_l = find(currL(left_list) == n_net);
            ind_r = find(currR(right_list) == n_net);
            precomputed_cort_idx{pi, n_net} = [ind_l, ind_r + 54216];
        end
    end
    
    % --- Ultimate memory fragmentation elimination: fully pre-allocate full-sized single-precision array matrices ---
    allNucleiFcsLeft = cell(num_perms_run, 7, 7);
    allNucleiFcsRight = cell(num_perms_run, 7, 7);
    for pi = 1:num_perms_run
        for n_nuc = 1:2:14
            idx_nuc = (n_nuc+1)/2;
            len_vec = (nuc_ends(n_nuc) - nuc_starts(n_nuc) + 1) * (nuc_ends(n_nuc) - nuc_starts(n_nuc)) / 2;
            len_vecR = (nuc_ends(n_nuc+1) - nuc_starts(n_nuc+1) + 1) * (nuc_ends(n_nuc+1) - nuc_starts(n_nuc+1)) / 2;
            for n_net = 1:7
                % Pre-fill with single-precision zeros at fixed addresses for subsequent accumulation
                allNucleiFcsLeft{pi, idx_nuc, n_net} = zeros(len_vec, 1, 'single');
                allNucleiFcsRight{pi, idx_nuc, n_net} = zeros(len_vecR, 1, 'single');
            end
        end
    end
    validSubNum = 0;
    
    % Step 3: Outer loop over subjects, each reads the 7GB file once
    for n_sub = 1:length(sub)
        tic
        fprintf('-- Block[%d-%d] Subject %d start reading and computing --\n', block_start, block_end, n_sub);
        
        h5_file = fullfile(FC_path, sub(n_sub).name, [sub(n_sub).name, '_Aligned_FC.h5']);
        if ~exist(h5_file, 'file') 
            error('Required aligned FC file is missing: %s', h5_file);
        end
        % Read directly as original single or double precision
        aligned_FCT = h5read(h5_file, '/aligned_FC'); 
        
        % <--- Move the nucleus loop (n_nuc) to the outermost level
        for n_nuc = 1:2:14
            idx_nuc = (n_nuc+1)/2;
            
            % Extract columns for the current nucleus
            nuc_chunk_L = aligned_FCT(:, nuc_starts(n_nuc) : nuc_ends(n_nuc));
            nuc_chunk_R = aligned_FCT(:, nuc_starts(n_nuc+1) : nuc_ends(n_nuc+1));
            
            for pi = 1:num_perms_run
                for n_net = 1:7
                    % Directly use the precomputed row indices, eliminating all find() operations!
                    cort_idx_net = precomputed_cort_idx{pi, n_net};
                    
                    X = nuc_chunk_L(cort_idx_net, :);
                    % 1. Left hemisphere: demean and correlate
                    X = X - mean(X, 1); 
                    normX = sqrt(sum(X.^2, 1));
                    normX(normX == 0) = 1; 
                    X = X ./ normX;
                    L_FCS = X' * X;

                    % Right hemisphere
                    Y = nuc_chunk_R(cort_idx_net, :);
                    Y = Y - mean(Y, 1);
                    normY = sqrt(sum(Y.^2, 1));
                    normY(normY == 0) = 1;
                    Y = Y ./ normY;
                    R_FCS = Y' * Y;
                    
                    L_FCS_vector = symmat2vec(L_FCS);
                    R_FCS_vector = symmat2vec(R_FCS);
                    
                    % Performance optimization 4: For the first valid subject, assign initial values directly, avoiding slow isempty checks each loop
                    allNucleiFcsLeft{pi, idx_nuc, n_net} = allNucleiFcsLeft{pi, idx_nuc, n_net} + single(L_FCS_vector(:));
                    allNucleiFcsRight{pi, idx_nuc, n_net} = allNucleiFcsRight{pi, idx_nuc, n_net} + single(R_FCS_vector(:));
                end
            end
        end
        % Free memory to prevent leaks
        clear aligned_FCT nuc_chunk_L nuc_chunk_R;
        java.lang.System.gc();
        validSubNum = validSubNum + 1;
        toc
    end
    
    assert(validSubNum > 0, 'No aligned FC files were available.');
    % Step 4: After accumulating all subjects in this block, perform the saving stage independently
    for pi = 1:num_perms_run
        p = perms_to_run(pi);
        rng(42 + p); % Restore the random seed for this permutation before clustering
        
        out_path = fullfile(parcellation_path, num2str(p));
        if ~exist(out_path,'dir')
            mkdir(out_path)
        end
        
        for n_nuc = 1:7
            k_value = k_list(n_nuc);
            % n_nuc takes values 1 to 7. Map to indices in the 14-length array:
            % e.g., nucleus 1 (ACCUMBENS): left index=1, right index=2
            idx_left = (n_nuc - 1)*2 + 1;
            idx_right = (n_nuc - 1)*2 + 2;
            
            % Number of voxels in the left hemisphere for this nucleus
            nVertL = nuc_ends(idx_left) - nuc_starts(idx_left) + 1;
            % Number of voxels in the right hemisphere for this nucleus
            nVertR = nuc_ends(idx_right) - nuc_starts(idx_right) + 1;

            L_parcellation = zeros(7, nVertL); 
            R_parcellation = zeros(7, nVertR);
            
            for n_net = 1:7
                FCS_L_avg = double(allNucleiFcsLeft{pi, n_nuc, n_net}) / validSubNum;
                FCS_R_avg = double(allNucleiFcsRight{pi, n_nuc, n_net}) / validSubNum;

                FCS_L_avg_thresh = FCS_L_avg.*(FCS_L_avg>0);
                FCS_R_avg_thresh = FCS_R_avg.*(FCS_R_avg>0);

                FCS_L_avg_mat = recon_symmat(FCS_L_avg_thresh);
                FCS_L_avg_mat = FCS_L_avg_mat+eye(size(FCS_L_avg_mat));

                FCS_R_avg_mat = recon_symmat(FCS_R_avg_thresh);
                FCS_R_avg_mat = FCS_R_avg_mat+eye(size(FCS_R_avg_mat));

                L_parcellation(n_net,:) = SpectralClustering_Larry(double(FCS_L_avg_mat), k_value, 3);
                R_parcellation(n_net,:) = SpectralClustering_Larry(double(FCS_R_avg_mat), k_value, 3);
            end
            save(fullfile(out_path, [nucNames{n_nuc}, '.mat']), 'L_parcellation', 'R_parcellation');
        end
        fprintf('>>> Loop %d clustering and saving successfully completed\n', p);
    end
end

function tf = is_perm_done(out_path, nucNames)
    if ~exist(out_path, 'dir')
        tf = false;
        return
    end

    tf = true;
    for i = 1:numel(nucNames)
        f = fullfile(out_path, [nucNames{i}, '.mat']);
        if exist(f, 'file') ~= 2
            tf = false;
            return
        end
    end
end
