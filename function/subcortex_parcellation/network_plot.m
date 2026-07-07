function network_plot(net, x_net_index, y_net_index, x_legends, y_legends,graph_title)
    % Compute unique network indices
    unique_x_nets = unique(x_net_index);
    unique_y_nets = unique(y_net_index);

    % Generate separator positions based on network indices
    x_sep = [0; cell2mat(arrayfun(@(id) max(find(x_net_index == id)), unique_x_nets, 'UniformOutput', false))];
    y_sep = [0; cell2mat(arrayfun(@(id) max(find(y_net_index == id)), unique_y_nets, 'UniformOutput', false))];
    
    % Plot network matrix
    imagesc(net); hold on;
    
    % Draw separation lines on x-axis
    x = repmat(x_sep', length(y_sep), 1)+0.5;
    y = repmat(y_sep, 1, length(x_sep))+0.5;
    mesh(x, y, zeros(size(x)), 'EdgeColor', 'k', 'FaceAlpha', 0, 'LineWidth', 0.5);
    view(2);
    grid off
    hold on;
    % Draw bars
    x_n_node = size(net,2);
    y_n_node = size(net,1);
    x_extend = x_n_node / 5;
    y_extend = x_extend*16/400;
    xlim([0.5-x_extend, x_n_node+x_extend+0.5]);
    ylim([0.5-y_extend, y_n_node+y_extend+0.5]);
    
    n_net_x = length(x_sep)-1;
    n_net_y = length(y_sep)-1;
    
    bar_sep_x = x_sep+0.5;
    bar_sep_y = y_sep+0.5;
    
%     width_of_legends_x = y_extend/4;
%     width_of_legends_y = width_of_legends_x*x_n_node/y_n_node;
    
    for i = 1 : n_net_x
        
            % X axis bar
%             y1 = bar_sep_y(end);
%             y2 = y1 + width_of_legends_x;
%             fill([bar_sep_x(i), bar_sep_x(i+1), bar_sep_x(i+1), bar_sep_x(i)], [y1,y1,y2,y2], 'r');

            % Y axis bar
%             x1 = bar_sep_x(1);
%             x2 = x1 - width_of_legends_y;
%             fill([x1,x1,x2,x2 ], [bar_sep_y(i), bar_sep_y(i+1), bar_sep_y(i+1), bar_sep_y(i)], 'r');

            % X axis label
            y1 = bar_sep_y(end);
            y_little_sep = y_extend/10;
            text((bar_sep_x(i+1) - bar_sep_x(i)) / 2 +  bar_sep_x(i), y1 + y_little_sep, ...
                x_legends{i}, 'fontsize', 10, 'rotation', -90);
    end
    for i = 1 : n_net_y
            % Y axis label
            x1 = bar_sep_x(1);
            x_little_sep = x_extend/1.5;
            text(x1 - x_little_sep, (bar_sep_y(i+1) - bar_sep_y(i)) / 2 +  bar_sep_y(i),...
                y_legends{i}, 'fontsize', 10, 'rotation', 0);
    end
    c = colorbar;
    c.Label.String = "Correlation (fisher's z)";
    c.FontSize = 8;
    c.Position = [0.8,0.2254,0.02,0.5841];
    
    t = title(graph_title,'Position',[200.5 0.1 0]);
    t.FontSize = 15;
    axis off

end