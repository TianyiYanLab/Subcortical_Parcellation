function fcs = cal_fcs(target_roi,ref_roi,data);
% Purpose: cal fcs.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
% calculate ROI average timeseries
% target_roi: The roi in which FCS will be calculated.A 3D matrix read from atlas nii file.
% ref_roi: The reference roi to construct connectivity fingerprints.A 3D matrix read from atlas nii file.
% data:Subject's fMRI data.A 4D matrix read from fMRI timeseries.
% [target_roi,ref_roi,data] = deal(sub_mask,GM_mask,sub_ima);

data = reshape(data,numel(data(:,:,:,1)),size(data,4));
data = zscore(data')';
cross = (target_roi~=0)&(ref_roi~=0);
[~,~,cross_in_ref] = intersect(find(cross),find(ref_roi~=0));
target_ts = data(target_roi~=0,:);
ref_ts = data(ref_roi~=0,:);
ref_ts(cross_in_ref,:)=[];
FC = corr(target_ts',ref_ts');
FC = atanh(FC);
FC(:,isnan(sum(FC)))=[];
if ~isempty(FC)
    fcs = corr(FC');
else
    fcs = [];
end
end
