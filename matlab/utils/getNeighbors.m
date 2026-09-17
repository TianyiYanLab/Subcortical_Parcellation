function nb = getNeighbors(atlas,boundaryInd,se)
% Purpose: getNeighbors.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
    nb = cell(length(boundaryInd),1);
    [x,y,z] = ind2sub(size(atlas),boundaryInd);
    for i = 1:length(boundaryInd)
        neighborhood = atlas(x(i)-1:x(i)+1,y(i)-1:y(i)+1,z(i)-1:z(i)+1);
        neighborhood = neighborhood(se.Neighborhood);
        nb{i} = unique(neighborhood(neighborhood>0));
    end
end
