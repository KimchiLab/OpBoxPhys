%%% PREPARATION OF SUBPLOTS %%%%%%%%%%%%%%%%%%%%%
function [axes_grid] = AxesGrid(num_rows, num_cols, boundaries, margins)

if nargin == 1 || (exist('num_cols', 'var') && isempty(num_cols))
    % Assume number of plots and square organization
    num_plots = num_rows;
    num_rows = ceil(num_plots^0.5);
    num_cols = ceil(num_plots / num_rows);
end

if nargin < 3 || isempty(boundaries)
    % boundaries like axis limits: left right, bottom top
%     boundaries = [0.02 0.99, 0.01 0.98];
    boundaries = [0.1 0.95, 0.05 0.95];
end

if nargin < 4 || isempty(margins)
    % Margins are in relative to grid cells/axes, rather than "absolute"/relative to page
    margins = [0.1 0.2 0.05];
end

frac_margin_inter_horiz = margins(1);
frac_margin_inter_vert = margins(2);

font_size = 9;

% Changes Text Interpreter so that underscores will print as underscores, rather than subcripts chars
set(0,'DefaultTextInterpreter','none')

% Calculate grid boundaries
total_width = diff(boundaries(1:2));
total_height = diff(boundaries(3:4));
data_left = boundaries(1);
data_top = boundaries(4);

% Calculate grid widths
putative_cell_width = total_width / (num_cols * (1 - frac_margin_inter_horiz) + (num_cols - 1) * frac_margin_inter_horiz);
cell_width = putative_cell_width * (1 - frac_margin_inter_horiz);
margin_inter_horiz = putative_cell_width * frac_margin_inter_horiz;

% Calculate grid heights
putative_cell_height = total_height / (num_rows * (1 - frac_margin_inter_vert) + (num_rows - 1) * frac_margin_inter_vert);
cell_height = putative_cell_height * (1 - frac_margin_inter_vert);
margin_inter_vert = putative_cell_height * frac_margin_inter_vert;

clear axes_grid
% axes_grid = []; % Otherwise axes become doubles
    
for i_row = 1:num_rows
    for i_col = 1:num_cols
        % position = [left bottom width height] http://www.mathworks.com/help/matlab/ref/axes-properties.html
        axes_grid(i_row, i_col) = axes('Position', ...
            [data_left + putative_cell_width * (i_col-1), ...
             data_top - (putative_cell_height * (i_row)) + margin_inter_vert, ...
             cell_width, ...
             cell_height]);
         
%             [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
%              data_top - (height*i_row) + (margin_inter_vert)/2, ...
%              width - margin_inter_horiz/2, ...
%              height - margin_inter_vert/2]);
% 
%         axes_raster(i_row, i_col) = axes('Position', ...
%             [data_left + putative_cell_width * (i_col-1), ...
%              data_top - (putative_cell_height * (i_row)) + margin_inter_vert + peth_height + margin_intra_vert, ...
%              cell_width, ...
%              raster_height]);
%         set(gca, 'FontSize', font_size);
%         axes_peth(i_row, i_col) = axes('Position', ...
%             [data_left + putative_cell_width * (i_col-1), ...
%              data_top - (putative_cell_height * (i_row)) + margin_inter_vert, ...
%              cell_width, ...
%              peth_height]);
        set(gca, 'FontSize', font_size);
%         axes_raster(i_row, i_col) = axes('Position', ...
%             [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
%              data_top - (height*i_row - peth_height) + (margin_intra_vert + margin_inter_vert)/2, ...
%              width - margin_inter_horiz/2, ...
%              raster_height - (margin_intra_vert + margin_inter_vert)/2]);
%         set(gca, 'FontSize', font_size);
%         axes_peth(i_row, i_col) = axes('Position', ...
%             [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
%              data_top - (height*i_row - margin_inter_vert), ...
%              width - margin_inter_horiz/2, ...
%              peth_height - (margin_intra_vert + margin_inter_vert)/2]);
%         set(gca, 'FontSize', font_size);
    end
end
%  	set(axes_raster, 'XTick', [], 'YTick', []);
%  	set(axes_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'XTick', [], 'YTick', []);
%  	set(grid_raster, 'Visible', 'off', 'XTick', [], 'YTick', [], 'Box', 'off', 'YDir','reverse');
%  	set(grid_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'FontSize', axis_font_size, 'XTickLabel', [], 'Box', 'off');


% 
% 
% if nargin < 3
%     % boundaries like axis limits: left right, bottom top
%     boundaries = [0.01 0.98, 0.01 0.98];
% end
% 
% if nargin == 4
%     margin_inter_horiz = margins(1);
%     margin_inter_vert = margins(2);
% else
%     % incorporate margins, esp for page, between pairs, and small within pair
%     margin_inter_horiz = 0.04;
%     margin_inter_vert = 0.07;
% end
% 
% font_size = 8;
% 
% % num_rows = 6;
% % num_cols = 4;
% 
% % Changes Text Interpreter so that 
% % underscores will print as underscores, rather than subcripts chars
% set(0,'DefaultTextInterpreter','none')
% 
% 
% data_left = boundaries(1);
% data_top = boundaries(4);
% width = diff(boundaries(1:2))/num_cols;
% height = diff(boundaries(3:4))/num_rows;
% 
% axes_grid = [];
%     
% for i_row = 1:num_rows
%     for i_col = 1:num_cols
%         % position = [left bottom width height]
%         axes_grid(i_row, i_col) = axes('Position', ...
%             [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
%              data_top - (height*i_row) + (margin_inter_vert)/2, ...
%              width - margin_inter_horiz/2, ...
%              height - margin_inter_vert/2]);
%         set(gca, 'FontSize', font_size);
%     end
% end
% %  	set(axes_raster, 'XTick', [], 'YTick', []);
% %  	set(axes_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'XTick', [], 'YTick', []);
% %  	set(grid_raster, 'Visible', 'off', 'XTick', [], 'YTick', [], 'Box', 'off', 'YDir','reverse');
% %  	set(grid_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'FontSize', axis_font_size, 'XTickLabel', [], 'Box', 'off');
% 
% 
% % %%
% % % Changes Text Interpreter so that 
% % % underscores will print as underscores, rather than subcripts chars
% % set(0,'DefaultTextInterpreter','none')
% % 
% % % incorporate margins, esp for page, between pairs, and small within pair
% % margin_inter_horiz = 0.04;
% % margin_inter_vert = 0.03;
% % font_size = 7;
% % 
% % % define major blocks. partition out rasters and peths within those blocks if desired?
% % % pos format: [left bottom width height]
% % data_bottom = 0.01;
% % data_top = 0.98;
% % data_left = 0.01;
% % data_right = 0.99;
% % 
% % width = (data_right - data_left)/num_cols;
% % height = (data_top - data_bottom)/num_rows;
% % 
% % axes_grid = [];
% %     
% % for i_row = 1:num_rows
% %     for i_col = 1:num_cols
% %         % position = [left bottom width height]
% %         axes_grid(i_row, i_col) = axes('Position', ...
% %             [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
% %              data_top - (height*i_row) + (margin_inter_vert)/2, ...
% %              width - margin_inter_horiz/2, ...
% %              height - margin_inter_vert/2]);
% %         set(gca, 'FontSize', font_size);
% %     end
% % end
% % %  	set(axes_raster, 'XTick', [], 'YTick', []);
% % %  	set(axes_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'XTick', [], 'YTick', []);
% % %  	set(grid_raster, 'Visible', 'off', 'XTick', [], 'YTick', [], 'Box', 'off', 'YDir','reverse');
% % %  	set(grid_peth, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'FontSize', axis_font_size, 'XTickLabel', [], 'Box', 'off');
