function boundary_info = getBoundary(subcor,se)
    subcor_region=size(unique(subcor),1)-1;    
    boundary_info = cell(subcor_region,2);
    for i = 1:subcor_region
        curr_parc = zeros(size(subcor));
        curr_parc(subcor==i)=1;
        bound = bwperim(curr_parc,6);
        bound_ind = find(bound);
        boundary_info{i,1} = bound_ind;
        boundary_info{i,2} = getNeighbors(subcor,bound_ind,se);
        out_ind = [];
        for j = 1:length(boundary_info{i,2})
            if length(boundary_info{i,2}{j})==1
                out_ind = [out_ind,j];
            end
        end
        boundary_info{i,1}(out_ind)=[];
        boundary_info{i,2}(out_ind)=[];
    end
end
function nb = getNeighbors(atlas,boundaryInd,se)
    nb = cell(length(boundaryInd),1);
    [x,y,z] = ind2sub(size(atlas),boundaryInd);
    for i = 1:length(boundaryInd)
        neighborhood = atlas(x(i)-1:x(i)+1,y(i)-1:y(i)+1,z(i)-1:z(i)+1);
        neighborhood = neighborhood(se.Neighborhood);
        nb{i} = unique(neighborhood(neighborhood>0));
    end
end