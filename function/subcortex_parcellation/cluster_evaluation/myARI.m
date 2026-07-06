function ARI = myARI(c1,c2)
N00 = 0;
N11 = 0;
N01 = 0;
N10 = 0;
for i = 1:length(c1)
    for j = i+1:length(c1)
        if c1(i) == c1(j) && c2(i) == c2(j)
            N11 = N11+1;
        elseif c1(i) ~= c1(j) && c2(i) ~= c2(j)
            N00 = N00+1;
        elseif c1(i) ~= c1(j) && c2(i) == c2(j)
            N01 = N01+1;
        elseif c1(i) == c1(j) && c2(i) ~= c2(j)
            N10 = N10+1;
        else
            disp('Huh?');
        end
    end
end
ARI = (2*(N00*N11-N01*N10))/((N00+N01)*(N01+N11)+(N00+N10)*(N10+N11));
end

