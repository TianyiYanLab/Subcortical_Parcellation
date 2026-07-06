function SI = similarity_silhouette(index,similarity)
    cluster_num = unique(index);
    distance = 1-similarity;
    SI = [];
    for i = 1:length(cluster_num)
        cluster_ind_i = find(index==i);
        avg_distance = zeros(length(cluster_ind_i),length(cluster_num));
        for j = 1:length(cluster_num)
            cluster_ind_j = find(index==j);
            i_j_distance = distance(cluster_ind_i,cluster_ind_j);
            avg_distance(:,j) = sum(i_j_distance,2)/(length(cluster_ind_i)-1);
        end
        a = avg_distance(:,i);
        avg_distance(:,i) = [];
        b = min(avg_distance,[],2);
        SI = [SI;(b-a)./max([a,b],[],2)];
    end
    SI = mean(SI);
end