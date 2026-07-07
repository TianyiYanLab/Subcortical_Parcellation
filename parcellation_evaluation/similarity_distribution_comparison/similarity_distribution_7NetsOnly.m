clear
all_perm_similarity_path = 'path/to/your/data\HCP\Robostic\all_perm_similarity';
out_dir = 'path/to/your/data\HCP\Robostic\similarity_distribution';
nucleus = {'SUBCORTEX'};

for i = 1:length(nucleus)
    load(fullfile(all_perm_similarity_path,[nucleus{i},'.mat']));
    within_net_similarity = zeros(7,1000);
    cross_net_similarity = zeros(42,1000);
    for j = 1:size(all_perm_similarity,3)
        curr_perm = all_perm_similarity(:,:,j);
        curr_within_net_similarity = diag(curr_perm);
        curr_cross_net_similarity =curr_perm-diag(diag(curr_perm));
        curr_cross_net_similarity = curr_cross_net_similarity(:);
        curr_cross_net_similarity(curr_cross_net_similarity==0)=[];
        within_net_similarity(:,j) = curr_within_net_similarity;
        cross_net_similarity(:,j) = curr_cross_net_similarity;
        fprintf('Nucleus: %d/%d, progress: %d/%d\n',i,1,j,1000);
    end
    save(fullfile(out_dir,[nucleus{i},'.mat']),'within_net_similarity','cross_net_similarity');
end
%% histogram
clear
distribution_dir = 'path/to/your/data\Parcellation\HCP_Lsym-AVR\Evaluation\Robostic\similarity_distribution';
nucleus = {'SUBCORTEX'};

for i = 1:length(nucleus)
    load(fullfile(distribution_dir,[nucleus{i},'.mat']));
    close all
    figure
    set(gcf,'unit','centimeters','position',[10 5 16 12]);
    h1 = histogram(cross_net_similarity(:),'Normalization','probability',...
        'BinWidth',0.002,'edgecolor',[0.301,0.745,0.933],'facecolor',[0.301,0.745,0.933]);
    hold on
    h2 = histogram(within_net_similarity(:),'Normalization','probability',...
    'BinWidth',0.002,'edgecolor',[0.635,0.078,0.184],'facecolor',[0.635,0.078,0.184]);
    hold on
    xlabel('Parcel similarity','FontSize',9);
    ylabel('Relative probability','FontSize',9);
    legend('Between-network similarity','Within-network similarity','Location','northwest')
    box off
%     title(nucleus{i},'FontSize',15,'FontWeight','bold')
    set(gca,'TickDir','out','linewidth',1,'FontSize',8)
    saveas(gca,fullfile(distribution_dir,[nucleus{i},'.png']));
end

%% K-S test
clear
distribution_dir = 'path/to/your/data\HCP\Robostic\similarity_distribution';
nucleus = {'SUBCORTEX'};

for i = 1:length(nucleus)
    load(fullfile(distribution_dir,[nucleus{i},'.mat']));
    [~,p(i),k(i)] = kstest2(within_net_similarity(:),cross_net_similarity(:));
end