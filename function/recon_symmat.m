function m = recon_symmat(v)
    sz = ceil(sqrt(length(v)*2));
    tu = triu(ones(sz),1);
    tu_ind = find(tu);
    m = zeros(sz);
    m(tu_ind) = v;
    m = m+m';
end