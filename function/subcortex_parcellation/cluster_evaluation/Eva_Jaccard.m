function [final_Jaccard,Jaccard_forward,Jaccard_backward] = Eva_Jaccard(cluster1,cluster2)
    %forward Jaccard
    nij = zeros(length(unique(cluster1)),length(unique(cluster2)));
    Jaccard_i = zeros(length(unique(cluster1)),1);
    for i = 1:length(unique(cluster1))
        for j = 1:length(unique(cluster2))
            nij(i,j) = length(intersect(find(cluster1==i),find(cluster2==j)))/length(union(find(cluster1==i),find(cluster2==j)));
        end
    end
    for k = 1:length(unique(cluster1))
        Jaccard_i(k) = max(nij(k,:));
    end
    Jaccard_forward = mean(Jaccard_i);

    % backward Jaccard
    nij = zeros(length(unique(cluster2)),length(unique(cluster1)));
    Jaccard_i = zeros(length(unique(cluster2)),1);
    for i = 1:length(unique(cluster2))
        for j = 1:length(unique(cluster1))
            nij(i,j) = length(intersect(find(cluster1==j),find(cluster2==i)))/length(union(find(cluster1==j),find(cluster2==i)));
        end
    end
    for k = 1:length(unique(cluster2))
        Jaccard_i(k) = max(nij(k,:));
    end
    Jaccard_backward = mean(Jaccard_i);

    final_Jaccard = (Jaccard_forward+Jaccard_backward)/2;
%     final_Jaccard = Jaccard_forward;
end
