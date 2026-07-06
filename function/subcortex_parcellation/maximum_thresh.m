function s_thresh=maximum_thresh(s)
    %Global thresholding. Haak et al 2017
    w=squareform(pdist(s));  %similarity to distance mapping

%     fprintf('Thresholding to minimum density needed for graph to remain connected\n');
    ind_upper=find(triu(ones(length(w),length(w)),1));
    [~,ind_srt]=sort(w(ind_upper));
    w_thresh=zeros(length(w),length(w));
    dns=linspace(0.001,1,1000);
    for i=1:length(dns)
        ttl=ceil(length(ind_upper)*dns(i));
        w_thresh(ind_upper(ind_srt(1:ttl)))=s(ind_upper(ind_srt(1:ttl)));
        [~,comp_sizes]=get_components(~~w_thresh+~~w_thresh');
        if length(comp_sizes)==1
            break
        end
    end

%     fprintf('Density=%0.2f%%\n',100*(length(find(~~w_thresh))/length(ind_upper)));
    dns=dns(i);
    w_thresh=w_thresh+w_thresh';
    s_thresh = w_thresh;
    
end