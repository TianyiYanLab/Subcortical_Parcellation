%% Standardize all subject labels
clear
all_sub_parcellation_path = 'D:\research\Robostic\all_sub_parcellation';
out_dir = 'D:\research\Robostic\relabeled_all_sub_parcellation';
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
warning off
sub_list = dir(all_sub_parcellation_path);
sub_list(1:2) = [];

for i = 1:length(nucleus)
    for j = 1:length(sub_list)
        tic 
        load(fullfile(all_sub_parcellation_path,sub_list(j).name,[nucleus{i},'.mat']));
        if j == 1
            example_parcellation = bilateral_parcellation;
            relabled_all_sub_parcellation = zeros([size(bilateral_parcellation),length(sub_list)]);
        else
        % 所有网络的标签和GM对齐
            for a = 1:size(bilateral_parcellation,2)
                [~,best_match] = iteration_Dice(bilateral_parcellation(:,a),example_parcellation(:,a));
                label = bilateral_parcellation(:,a);
                for b = 1:length(best_match)
                    ind{b} = find(label==b);
                end
                for b = 1:length(best_match)
                    label(ind{b}) = best_match(b);
                end
                bilateral_parcellation(:,a) = label;
            end
        end
        relabled_all_sub_parcellation(:,:,j) = bilateral_parcellation;
        fprintf('Nucleus: %d/%d, progress: %d/%d\n',i,j,length(sub_list));
        toc
    end
    save(fullfile(out_dir,[nucleus{i},'.mat']),'relabled_all_sub_parcellation');
end
%% combine_all_nucleus_parcellation
clear
relabeled_all_sub_parcellation_dir = 'D:\research\Robostic\relabeled_all_sub_parcellation';
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
out_dir = 'D:\research\Robostic\relabeled_all_sub_parcellation';

cum = 0;
all_nucleus_parcellation = [];
for i = 1:length(nucleus)
    load(fullfile(relabeled_all_sub_parcellation_dir,[nucleus{i},'.mat']));
    curr_nuclei = relabled_all_sub_parcellation;
    parcel_num = length(unique(curr_nuclei));
    curr_nuclei = curr_nuclei+cum;
    all_nucleus_parcellation = cat(1,all_nucleus_parcellation,curr_nuclei);
    cum = cum+parcel_num;
end
relabled_all_sub_parcellation = all_nucleus_parcellation;
save(fullfile(out_dir,['SUBCORTEX.mat']),'relabled_all_sub_parcellation');