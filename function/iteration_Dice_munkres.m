function [Dice,assignment] = iteration_Dice_munkres(cluster1,cluster2)
    nij = zeros(length(unique(cluster1)),length(unique(cluster2)));
    for i = 1:length(unique(cluster1))
        for j = 1:length(unique(cluster2))
            nij(i,j) = 2*length(intersect(find(cluster1==i),find(cluster2==j)))/(length(find(cluster1==i))+length(find(cluster2==j)));
        end
    end
    cost = max(max(nij))-nij;
%     cost = 1-nij;
    assignment = munkres(cost);
    for i = 1:size(nij,1)
        Dice(i) = nij(i,assignment(i));
    end
    Dice = mean(Dice);
end