function [Dice,best_match] = iteration_Dice(cluster1,cluster2)
    nij = zeros(length(unique(cluster1)),length(unique(cluster2)));
    for i = 1:length(unique(cluster1))
        for j = 1:length(unique(cluster2))
            nij(i,j) = 2*length(intersect(find(cluster1==i),find(cluster2==j)))/(length(find(cluster1==i))+length(find(cluster2==j)));
        end
    end
    Dice = [];
    best_match = zeros(length(unique(cluster1)),1);
    for a = 1:size(nij,1)
        if ~isempty(find(nij>0))
            if ~isempty(find(sum(nij~=0,2)==1))
                x = find(sum(nij~=0,2)==1);
                for i = 1:length(x)
                    y(i,:) = find(nij(x(i),:));
                    Dice = [Dice;nij(x(i),y(i))];
                end
                best_match(x) = y;
                nij(x,:) = 0;
                nij(:,y) = 0;
                clear x y
            else
                [x,y] = find(nij==max(nij,[],'all'),1);
                Dice = [Dice;nij(nij==max(nij,[],'all'))];
                best_match(x) = y;
                nij(x,:) = 0;
                nij(:,y) = 0;
                clear x y
            end
        end
    end
    Dice = mean(Dice);
%     varargout = {best_match};
end