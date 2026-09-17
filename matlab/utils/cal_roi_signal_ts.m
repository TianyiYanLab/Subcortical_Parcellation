function roi_ts_mean = cal_roi_signal_ts(atlas,data,num_of_region);
% Purpose: cal roi signal ts.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
% calculate ROI average timeseries
% atlas: A 3D matrix, read from atlas nii file.
% data:A 4D matrix, read from fMRI timeseries.
% num_of_region:the number of regions in atlas
data = reshape(data,numel(data(:,:,:,1)),size(data,4));
data = zscore(data')';
for i = 1:num_of_region
    curr_roi_ind = find(atlas==i);
    curr_roi_ts = data(curr_roi_ind,:);
    if size(curr_roi_ts,1)>1
        roi_ts_mean(:,i) = mean(curr_roi_ts);
    else
        roi_ts_mean(:,i) = curr_roi_ts;
    end
end
end
