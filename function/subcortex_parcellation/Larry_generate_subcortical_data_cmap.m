function [colormap,real_colorscale] = Larry_generate_subcortical_data_cmap(input_vec,lims,cmap,discretization_res)

%% This function will project a vector onto the Schaefer 400 parcellation

% Required inputs
% - input_vec: a 1x400 vector
% - out_dir: path to an output directory
% - lims: min and max values for colour scale e.g. [0 100]
% - cmap: a string that specifies what colour map is needed. Options are
% 'hot' or 'cold'
%
% Written by Ruby Kong & CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

%%

%SET min and max threshold for colorbar:
min_th = lims(1);
max_th = lims(2);

%SET annot file output filename:
input_vec(isnan(input_vec)) = 0;
colorscale = CBIG_GenerateColorscale(cmap);
value_step = (max_th - min_th) / (discretization_res-2);
binranges = (min_th-value_step):value_step:(max_th+value_step);
[~, bin_ind] = histc(input_vec, binranges);
bin_ind(input_vec == 0) = discretization_res+1;
% underlay the new annotation with gray color saved at the end of the new
colorscale(141,:) = [128 128 128]/255;
colormap = colorscale(bin_ind,:);
real_colorscale = colorscale(1:140,:);
end


function colorscale = CBIG_GenerateColorscale(cmap)
    res = 140;
    if strcmp(cmap, 'hot')
        RGB_new = [255 0 0;
            255 31  31;
            255 56  56;
            255 92  92;
            255 120 120;
            255 158 158;
            255 186 186;
            255 214 214;
            255 255 255];
    end
    if strcmp(cmap, 'cold')
        RGB_new = [0 0 255;
            31  31  255;
            56  56  255;
            92  92  255;
            120 120 255;
            158 158 255;
            186 186 255;
            214 214 255;
            255 255 255];
    end
    if strcmp(cmap, 'red_yell')
        RGB_new = [255 255 255;
            255 236 94;
            232 208 28;
            181 148 0;
            181 97  0;
            181 51  0;
            181 0   0;
            117 0   0;
            0   0   0];
    end
    if strcmp(cmap, 'blue_cyan')
        RGB_new = [255 255 255;
            179 255 251;
            43  224 215;
            43  182 224;
            43  155 224;
            43  118 224;
            13  75  184;
            0   43  117;
            0   0   0]; 
    end
    if strcmp(cmap, 'hot_cold')
        RGB_new = [250 241 182;
            250 208 70;
            255 140 0;
            255 0   0;
            0   0   0;
            0   0   255;
            0   140 255;
            70  208 250;
            182 241 250];
    end
            
    RGB_COLORSCALE = RGB_new;
    orig_colorscale_length = size(RGB_COLORSCALE, 1);
    colorscale = [];
    step = round(res / orig_colorscale_length);
    
    count = 1;
    for i = 1:orig_colorscale_length-1
        for j = 0:step-1
            colorscale(count, :) = RGB_COLORSCALE(i, :) * (step - j) + RGB_COLORSCALE(i+1, :) * j;
            colorscale(count, :) = colorscale(count, :) * 1.0 / step;
            count = count + 1;
        end
    end
    colorscale = [colorscale; RGB_COLORSCALE(orig_colorscale_length, :)];
    
    pad = (res - size(colorscale, 1)) / 2;
    for i = 1:pad
        colorscale = [RGB_COLORSCALE(1, :); colorscale];
    end
    
    pad = res - size(colorscale, 1);
    for i = 1:pad
        colorscale = [colorscale; RGB_COLORSCALE(orig_colorscale_length, :)];
    end
    
    colorscale = flipud(colorscale) / 255;
end