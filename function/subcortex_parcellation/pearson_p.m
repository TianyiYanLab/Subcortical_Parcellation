function p = pearson_p(r,n,tail)
    if nargin <3
        tail = 'both';
    end
    t = r*sqrt((n-2)/(1-r^2));
    df = n-2;
    if strcmp(tail,'both')
        p = 1-tcdf(abs(t),df);
        p = p*2;
    elseif strcmp(tail,'larger')
        p = 1-tcdf(t,df);
    elseif strcmp(tail,'smaller')
        p = tcdf(t,df);
    end
end