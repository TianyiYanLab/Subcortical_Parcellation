function [v,sz,tu] = symmat2vec(original_mat)
    sz = size(original_mat);
    tu = triu(ones(sz),1);
    tu = find(tu);
    v = original_mat(tu);
end