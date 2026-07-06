function [final_Dice,Dice_forward,Dice_backward] = Eva_Dice(cluster1,cluster2)
    %forward Dice
    nij = zeros(length(unique(cluster1)),length(unique(cluster2)));
    Dice_i = zeros(length(unique(cluster1)),1);
    for i = 1:length(unique(cluster1))
        for j = 1:length(unique(cluster2))
            nij(i,j) = 2*length(intersect(find(cluster1==i),find(cluster2==j)))/(length(find(cluster1==i))+length(find(cluster2==j)));
        end
    end
    for k = 1:length(unique(cluster1))
        Dice_i(k) = max(nij(k,:));
    end
    Dice_forward = mean(Dice_i);

    % backward Dice
    nij = zeros(length(unique(cluster2)),length(unique(cluster1)));
    Dice_i = zeros(length(unique(cluster2)),1);
    for i = 1:length(unique(cluster2))
        for j = 1:length(unique(cluster1))
            nij(i,j) = 2*length(intersect(find(cluster1==j),find(cluster2==i)))/(length(find(cluster1==j))+length(find(cluster2==i)));
        end
    end
    for k = 1:length(unique(cluster2))
        Dice_i(k) = max(nij(k,:));
    end
    Dice_backward = mean(Dice_i);

    final_Dice = (Dice_forward+Dice_backward)/2;
%     final_Dice = Dice_forward;
end
