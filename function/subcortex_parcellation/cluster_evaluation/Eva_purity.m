function [final_purity,purity_forward,purity_backward] = Eva_purity(cluster1,cluster2)
    %forward purity
    nij = zeros(length(unique(cluster1)),length(unique(cluster2)));
    purity_i = zeros(length(unique(cluster1)),1);
    for i = unique(cluster1)
        for j = unique(cluster2)
            nij(i,j) = length(intersect(find(cluster1==i),find(cluster2==j)));
        end
    end
    for k = 1:length(unique(cluster1))
        purity_i(k) = max(nij(k,:))/length(cluster1);
    end
    purity_forward = sum(purity_i);

    % backward purity
    nij = zeros(length(unique(cluster2)),length(unique(cluster1)));
    purity_i = zeros(length(unique(cluster2)),1);
    for i = unique(cluster2)
        for j = unique(cluster1)
            nij(i,j) = length(intersect(find(cluster2==i),find(cluster1==j)));
        end
    end
    for k = 1:length(unique(cluster2))
        purity_i(k) = max(nij(k,:))/length(cluster2);
    end
    purity_backward = sum(purity_i);

    final_purity = (purity_forward+purity_backward)/2;
%     final_purity = purity_forward;
end
