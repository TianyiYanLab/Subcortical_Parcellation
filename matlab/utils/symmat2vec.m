function [v,sz,tu] = symmat2vec(original_mat)
% Purpose: symmat2vec.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
    sz = size(original_mat);
    tu = triu(ones(sz),1);
    tu = find(tu);
    v = original_mat(tu);
end
