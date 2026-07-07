function [C, L, U, value] = SpectralClustering_multiK_Larry(W, k, Type)
%SPECTRALCLUSTERING Executes spectral clustering algorithm
%   Executes the spectral clustering algorithm defined by
%   Type on the adjacency matrix W and returns the k cluster
%   indicator vectors as columns in C.
%   If L and U are also called, the (normalized) Laplacian and
%   eigenvectors will also be returned.
%
%   'W' - Adjacency matrix, needs to be square
%   'k' - Max Number of clusters to look for.Which means this function will
%   return cluster solution from k=2:k;
%   'Type' - Defines the type of spectral clustering algorithm
%            that should be used. Choices are:
%      1 - Unnormalized
%      2 - Normalized according to Shi and Malik (2000)
%      3 - Normalized according to Jordan and Weiss (2002)
%

degs = sum(W, 2);
D    = sparse(1:size(W, 1), 1:size(W, 2), degs);
% compute unnormalized Laplacian
L = D - W;
% compute normalized Laplacian if needed
switch Type
    case 2
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate inverse of D
        D = spdiags(1./degs, 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L;
        

        
    case 3
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate D^(-1/2)
        D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L * D;
end
% compute the eigenvectors corresponding to the k smallest
% eigenvalues
% warning('off','last');
% use eig
[U, value] = eig(L);
value = diag(value);
[value,ind] = sort(value);
U = U(:,ind);
idx=find(abs(value)>eps);
starting=idx(1);
U = U(:,starting:starting+k-1);

%[U, ~] = eigs(L, k, 'smallestreal');
% in case of the Jordan-Weiss algorithm, we need to normalize
% the eigenvectors row-wise

for i = 2:k
    curr_U = U(:,1:i);
    if Type == 3
        curr_U = bsxfun(@rdivide, curr_U, sqrt(sum(curr_U.^2, 2)));
        C(:,i-1) = kmeans(curr_U, i, 'EmptyAction', 'error','Replicates',50);
    else
        C(:,i-1) = kmeans(curr_U, i, 'EmptyAction', 'error','Replicates',50);
    end
end
% now use the k-means algorithm to cluster U row-wise
% C will be a n-by-1 matrix containing the cluster number for
% each data point, minus 1 for the consistant with the true label.

% now convert C to a n-by-k matrix containing the k indicator
% vectors as columns
% C = sparse(1:size(D, 1), C, 1);
end