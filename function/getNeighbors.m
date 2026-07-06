function nb = getNeighbors(atlas,boundaryInd,se)
    nb = cell(length(boundaryInd),1);
    [x,y,z] = ind2sub(size(atlas),boundaryInd);
    for i = 1:length(boundaryInd)
        neighborhood = atlas(x(i)-1:x(i)+1,y(i)-1:y(i)+1,z(i)-1:z(i)+1);
        neighborhood = neighborhood(se.Neighborhood);
        nb{i} = unique(neighborhood(neighborhood>0));
    end
end