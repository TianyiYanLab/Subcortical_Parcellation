function m = recon_symmat(v)
% Purpose: recon symmat.
% Input: Function arguments or repository-relative data/results paths; see README.md.
% Output: Return values or workspace arrays; see README.md.
% Dependencies: MATLAB R2019b; see README.md.
    sz = ceil(sqrt(length(v)*2));
    tu = triu(ones(sz),1);
    tu_ind = find(tu);
    m = zeros(sz);
    m(tu_ind) = v;
    m = m+m';
end
