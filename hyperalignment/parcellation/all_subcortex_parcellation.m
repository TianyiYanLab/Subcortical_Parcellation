%% Accumulated FCS version
clear
FCS_path = 'F:\hyperalignment\forward_results';
% FCS_mean_path = 'D:\research\Parcellation\hyperalignment\FCS_mean';
mask_path = 'D:\research\Parcellation\template\nucleus_mask';
out_path = 'D:\research\Parcellation\hyperalignment\parcellation\results';

nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
k_list = [2,2,3,5,2,6,5];

warning off
subList = dir(FCS_path);
subList(1:2,:) = [];

for indNucleus = 6:7
    all_sub_FCS = cell(2,8);
    left_parcellation = [];
    right_parcellation = [];
    fprintf('loading FCS_mat\n')
    for indSub = 1:length(subList)
        load(fullfile(FCS_path,subList(indSub).name,[nucleus{indNucleus},'.mat']));
        for indNet = 1:size(FCS,2)
            if indSub == 1
                all_sub_FCS{1,indNet} = FCS{1,indNet};
                all_sub_FCS{2,indNet} = FCS{2,indNet};
            else
                all_sub_FCS{1,indNet} = all_sub_FCS{1,indNet}+FCS{1,indNet};
                all_sub_FCS{2,indNet} = all_sub_FCS{2,indNet}+FCS{2,indNet};
            end
        end
    end
    fprintf('all FCS mat loaded\n')
    [~,left_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
    [~,right_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_RIGHT.nii']));
    k = k_list(indNucleus);
%     for indNet = 1:size(all_sub_FCS,2)
%         all_sub_FCS{1,indNet} = mean(all_sub_FCS{1,indNet},2);
%         all_sub_FCS{2,indNet} = mean(all_sub_FCS{2,indNet},2);
%     end
    out = fullfile(out_path,nucleus{indNucleus});
    if ~exist(out)
        mkdir(out);
    end
    
    % Clustering
    for indNet = 1:size(all_sub_FCS,2)
        leftW = double(all_sub_FCS{1,indNet}/length(subList));
        leftW = leftW.*(leftW>0);
        leftW = recon_symmat(leftW);
        leftW = leftW+eye(size(leftW));
        rightW = double(all_sub_FCS{2,indNet}/length(subList));
        rightW = rightW.*(rightW>0);
        rightW = recon_symmat(rightW);
        rightW = rightW+eye(size(rightW));
        
        left_parcellation(:,indNet) = SpectralClustering_Larry(leftW,k,3);
        right_parcellation(:,indNet) = SpectralClustering_Larry(rightW,k,3);
    end
    
    % Align labels of all networks with GM
    for indNet = 1:size(all_sub_FCS,2)
        [~,best_match] = iteration_Dice_munkres(left_parcellation(:,indNet),left_parcellation(:,1));
        label = left_parcellation(:,indNet);
        for b = 1:length(best_match)
            ind{b} = find(label==b);
        end
        for b = 1:length(best_match)
            label(ind{b}) = best_match(b);
        end
        left_parcellation(:,indNet) = label;
        left_visualization = left_mask;
        left_visualization(find(left_visualization)) = left_parcellation(:,indNet);
%         mat2nii(left_visualization,fullfile(out,[labels{a},'_',nucleus{i},'_L.nii']),size(left_visualization),32,[mask_path,nucleus{i},'_L.nii']);
    end
    
    % Align left and right hemispheres across networks
    for indNet = 1:size(all_sub_FCS,2)
        [~,best_match] = bilateral_symmetry_munkres(left_parcellation(:,indNet),right_parcellation(:,indNet),left_mask,right_mask);
        label = right_parcellation(:,indNet);
        for b = 1:length(best_match)
            ind{b} = find(label==b);
        end
        for b = 1:length(best_match)
            label(ind{b}) = best_match(b);
        end
        right_parcellation(:,indNet) = label;
    end
    
    % Visualization
    for indNet = 1:size(all_sub_FCS,2)
        parcellation = left_mask;
        parcellation(find(left_mask)) = left_parcellation(:,indNet);
        parcellation(find(right_mask)) = right_parcellation(:,indNet);
        mat2nii(parcellation,fullfile(out,[labels{indNet},'_',nucleus{indNucleus},'.nii']),size(parcellation),32,fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
    end
    fprintf('%d finished\n',indNucleus)
end

%% Spectral clustering with direct unified labels and visualization
clear
FCS_path = 'F:\hyperalignment\forward_results';
% FCS_mean_path = 'D:\research\Parcellation\hyperalignment\FCS_mean';
mask_path = 'D:\research\Parcellation\template\nucleus_mask';
out_path = 'D:\research\Parcellation\hyperalignment\parcellation\results';

nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
k_list = [2,2,3,5,2,6,5];

warning off
subList = dir(FCS_path);
subList(1:2,:) = [];

for indNucleus = 6:7
    all_sub_FCS = cell(2,8);
    left_parcellation = [];
    right_parcellation = [];
    fprintf('loading FCS_mat\n')
    for indSub = 1:length(subList)
        load(fullfile(FCS_path,subList(indSub).name,[nucleus{indNucleus},'.mat']));
        for indNet = 1:size(FCS,2)
            all_sub_FCS{1,indNet} = [all_sub_FCS{1,indNet},FCS{1,indNet}];
            all_sub_FCS{2,indNet} = [all_sub_FCS{2,indNet},FCS{2,indNet}];
        end
    end
    fprintf('all FCS mat loaded\n')
    [~,left_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
    [~,right_mask] = read(fullfile(mask_path,[nucleus{indNucleus},'_RIGHT.nii']));
    k = k_list(indNucleus);
%     for indNet = 1:size(all_sub_FCS,2)
%         all_sub_FCS{1,indNet} = mean(all_sub_FCS{1,indNet},2);
%         all_sub_FCS{2,indNet} = mean(all_sub_FCS{2,indNet},2);
%     end
    out = fullfile(out_path,nucleus{indNucleus});
    if ~exist(out)
        mkdir(out);
    end
    
    % Clustering
    for indNet = 1:size(all_sub_FCS,2)
        leftW = double(mean(all_sub_FCS{1,indNet},2));
        leftW = leftW.*(leftW>0);
        leftW = recon_symmat(leftW);
        leftW = leftW+eye(size(leftW));
        rightW = double(mean(all_sub_FCS{2,indNet},2));
        rightW = rightW.*(rightW>0);
        rightW = recon_symmat(rightW);
        rightW = rightW+eye(size(rightW));
        
        left_parcellation(:,indNet) = SpectralClustering_Larry(leftW,k,3);
        right_parcellation(:,indNet) = SpectralClustering_Larry(rightW,k,3);
    end
    
    % Align labels of all networks with GM
    for indNet = 1:size(all_sub_FCS,2)
        [~,best_match] = iteration_Dice_munkres(left_parcellation(:,indNet),left_parcellation(:,1));
        label = left_parcellation(:,indNet);
        for b = 1:length(best_match)
            ind{b} = find(label==b);
        end
        for b = 1:length(best_match)
            label(ind{b}) = best_match(b);
        end
        left_parcellation(:,indNet) = label;
        left_visualization = left_mask;
        left_visualization(find(left_visualization)) = left_parcellation(:,indNet);
%         mat2nii(left_visualization,fullfile(out,[labels{a},'_',nucleus{i},'_L.nii']),size(left_visualization),32,[mask_path,nucleus{i},'_L.nii']);
    end
    
    % Align left and right hemispheres across networks
    for indNet = 1:size(all_sub_FCS,2)
        [~,best_match] = bilateral_symmetry_munkres(left_parcellation(:,indNet),right_parcellation(:,indNet),left_mask,right_mask);
        label = right_parcellation(:,indNet);
        for b = 1:length(best_match)
            ind{b} = find(label==b);
        end
        for b = 1:length(best_match)
            label(ind{b}) = best_match(b);
        end
        right_parcellation(:,indNet) = label;
    end
    
    % Visualization
    for indNet = 1:size(all_sub_FCS,2)
        parcellation = left_mask;
        parcellation(find(left_mask)) = left_parcellation(:,indNet);
        parcellation(find(right_mask)) = right_parcellation(:,indNet);
        mat2nii(parcellation,fullfile(out,[labels{indNet},'_',nucleus{indNucleus},'.nii']),size(parcellation),32,fullfile(mask_path,[nucleus{indNucleus},'_LEFT.nii']));
    end
    fprintf('%d finished\n',indNucleus)
end