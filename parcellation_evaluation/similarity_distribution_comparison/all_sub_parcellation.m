%% Spectral clustering for all subjects, directly unify labels
clear
FCS_path = 'path/to/your/data\subcortex_noPCA_FCS_all';
out_path = 'path/to/your/data\Robostic\all_sub_parcellation';
nucleus = {'ACCUMBENS','AMYGDALA','CAUDATE','HIPPOCAMPUS','PALLIDUM','PUTAMEN','THALAMUS'};
warning off
labels = {'GM','VIS','SMN','DAN','VAN','LIM','FPN','DMN'};
k_list = [2,2,3,5,3,6,3];% noPCA
sub_list = dir(FCS_path);
sub_list(1:2) = [];

for i = 1:length(nucleus)
    k = k_list(i);
    for j = 1:length(sub_list)
        tic
        load(fullfile(FCS_path,sub_list(j).name,[nucleus{i},'.mat']));
        out = fullfile(out_path,sub_list(j).name);
        if ~exist(out)
            mkdir(out);
        end
        
        % Clustering
        for a = 1:size(FCS,2)
            leftW = double(FCS{1,a});
            leftW = leftW.*(leftW>0);
            rightW = double(FCS{2,a});
            rightW = rightW.*(rightW>0);

            left_parcellation(:,a) = SpectralClustering(k,leftW);
            right_parcellation(:,a) = SpectralClustering(k,rightW);
        end
        bilateral_parcellation = [left_parcellation;right_parcellation+k];% Left and right labels must be distinct
%         bilateral_parcellation = [left_parcellation;right_parcellation];
        clear left_parcellation right_parcellation
        
        % Align labels of all networks with GM
        for a = 1:size(FCS,2)
            [~,best_match] = iteration_Dice(bilateral_parcellation(:,a),bilateral_parcellation(:,1));
            label = bilateral_parcellation(:,a);
            for b = 1:length(best_match)
                ind{b} = find(label==b);
            end
            for b = 1:length(best_match)
                label(ind{b}) = best_match(b);
            end
            bilateral_parcellation(:,a) = label;
        end
        save(fullfile(out,[nucleus{i},'.mat']),'bilateral_parcellation');
        fprintf('Nucleus %d in progress, progress: %d/%d\n',i,j,length(sub_list));
        toc
    end
end