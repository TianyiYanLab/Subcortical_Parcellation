function [symmetry,best_match] = bilateral_symmetry_munkres(left_parcellation,right_parcellation,left_mask,right_mask)
    left_ind = find(left_mask);
    right_ind = find(right_mask);
    left_mask(left_ind) = left_parcellation;
    right_mask(right_ind) = right_parcellation;
%     mat2nii(left_mask,'left_mask.nii',size(left_mask),32,'D:\Data\research\subcortex parcellation\results\0.9PCA mean_0thresh\ACCUMBENS\mask\ACCUMBENS_L.nii');
%     mat2nii(right_mask,'right_mask.nii',size(right_mask),32,'D:\Data\research\subcortex parcellation\results\0.9PCA mean_0thresh\ACCUMBENS\mask\ACCUMBENS_L.nii');

    % First compute symmetric mask
    L2R_mask = single(zeros(size(left_mask)));
%     R2L_mask = single(zeros(size(right_mask)));
    for i = 1:size(left_mask,2)
        L2R_mask(:,i,:) = flipud(squeeze(left_mask(:,i,:)));
%         R2L_mask(:,i,:) = flipud(squeeze(right_mask(:,i,:)));
    end
%     mat2nii(L2R_mask,'L2R_mask.nii',size(L2R_mask),32,'D:\Data\research\subcortex parcellation\template\nucleus_mask\ACCUMBENS_L.nii');
%     mat2nii(R2L_mask,'R2L_mask.nii',size(R2L_mask),32,'D:\Data\research\subcortex parcellation\results\0.9PCA mean_0thresh\ACCUMBENS\mask\ACCUMBENS_L.nii');
    % L2R overlap
    L2R_ind = find(L2R_mask);
    [~,ia,ib] = intersect(L2R_ind,right_ind);
    L2R_parcellation = L2R_mask(L2R_ind);
    L2R_intersection = L2R_parcellation(ia);
    right_intersection = right_parcellation(ib);
    [L2R_Dice,best_match] = iteration_Dice_munkres(right_intersection,L2R_intersection); % best_match is the label mapping from right parcellation to left parcellation
    symmetry = L2R_Dice;
    
%     % R2L overlap
%     R2L_ind = find(R2L_mask);
%     [~,ia,ib] = intersect(R2L_ind,left_ind);
%     R2L_parcellation = R2L_mask(R2L_ind);
%     R2L_intersection = R2L_parcellation(ia);
%     left_intersection = left_parcellation(ib);
%     R2L_Dice = iteration_Dice(R2L_intersection,left_intersection);
    
%     symmetry = (L2R_Dice+R2L_Dice)/2;
end