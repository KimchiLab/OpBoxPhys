%% PREPARATION OF SUBPLOTS
% function [grid_raster, grid_peth, figures] = AxesEEGs(total_rows, total_cols, raster_ratio, max_rows, max_cols);
% max_cols function is not currently working, need to be specified in total_cols, can adjust later to extend right over figures (in addition to down, which is already done)
function [axes_time, axes_freq, axes_ep, axes_cam, figures] = OpBox_Axes(num_subj)

% Changes Text Interpreter so that 
% underscores will print as underscores, rather than subcripts chars
set(0,'DefaultTextInterpreter','none')

% incorporate margins, esp for page, between pairs, and small within pair
max_rows = 4;
max_cols = 4;
% total_cols = 1;
% margin_intra_vert = 0.015; % Higher-Res: absolute margins so as to accomodate fonts for a given screen resolution
margin_intra_vert = 0.03; % Lower-Res: absolute margins so as to accomodate fonts for a given screen resolution
margin_inter_horiz = 0.1;
margin_intra_horiz = 0.025;
margin_inter_vert = 0.025;
time_ratio_vert = 0.6;
freq_ratio_horiz = 0.7;
phys_ratio_horiz = 0.8;
font_size = 7;

% define major blocks. partition out rasters and peths within those blocks if desired?
% pos format: [left bottom width height]
data_bottom = 0.01;
data_top = 0.99;
data_left = 0.005;
data_right = 0.99;

% calculate the number of rows to use. may be different on last page
num_rows = min([num_subj, max_rows]);
% calculate the number of cols to use. may be different on last page
num_cols = min([ceil(num_subj/num_rows), max_cols]);
% calculate the number of figures needed
num_figs = ceil(num_subj / (num_rows * num_cols));
% now scale down number of rows
num_rows = ceil(num_subj/num_cols / num_figs);
% num_cols = min([total_cols, max_cols]);
% num_cols = total_cols;

i_total_subj = 0;
width = (data_right - data_left)/num_cols;
height = (data_top - data_bottom)/num_rows;
% margin_width = width * margin_ratio / 2;
% margin_height = height * margin_ratio;
time_height = height * time_ratio_vert;
freq_height = height - time_height;
phys_width = width * phys_ratio_horiz;
freq_width = phys_width * freq_ratio_horiz;
ep_width = phys_width - freq_width;
% cam_width = width - phys_width;

figures = gobjects(num_figs, 1);
axes_time = gobjects(num_subj, 1);
axes_freq = gobjects(num_subj, 1);
axes_ep = gobjects(num_subj, 1);
axes_cam = gobjects(num_subj, 1);

for i_fig = 1:num_figs
    if 1 == num_figs
        figures(i_fig) = clf;
    else
        figures(i_fig) = figure;
    end

    % Go across and then down (though prioritize columns rather than rows above)
    for i_row = 1:num_rows
        for i_col = 1:num_cols
            i_total_subj = i_total_subj + 1;
            if i_total_subj > num_subj
                break
            end
            % position = [left bottom width height]
            % Time axes
            axes_time(i_total_subj) = axes('Position', ...
                [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
                 data_top - (height*i_row - freq_height) + (margin_intra_vert + margin_inter_vert)/2, ...
                 phys_width - margin_inter_horiz/2, ...
                 time_height - (margin_intra_vert + margin_inter_vert)/2]);
            if i_row == num_rows
                xlabel('Time (sec)');
            end
            ylabel('Volt');
            set(gca, 'FontSize', font_size);
            hold on;
            
            % Freq axes
            axes_freq(i_total_subj) = axes('Position', ...
                [data_left + width*(i_col-1) + margin_inter_horiz/2, ...
                 data_top - (height*i_row - margin_inter_vert), ...
                 freq_width - margin_intra_horiz/2  - margin_inter_horiz/4, ...
                 freq_height - (margin_intra_vert + margin_inter_vert)/2]);
            set(gca, 'XMinorTick', 'on');
            set(gca, 'YGrid', 'on');
            if i_row == num_rows
                xlabel('');
            end
            ylabel('Power');
            set(gca, 'FontSize', font_size);
            hold on;
             
            % EP axes
            axes_ep(i_total_subj) = axes('Position', ...
                [data_left + width*(i_col-1) + freq_width + margin_intra_horiz/2 + margin_inter_horiz/4, ...
                 data_top - (height*i_row - margin_inter_vert), ...
                 ep_width - margin_intra_horiz/2  - margin_inter_horiz/4, ...
                 freq_height - (margin_intra_vert + margin_inter_vert)/2]);
            if i_row == num_rows
                xlabel('Peri-time (ms)');
            end
            set(gca, 'Box', 'off');
            ylabel('EP');
            set(gca, 'FontSize', font_size);
            hold on;

            % Cam axes
            axes_cam(i_total_subj) = axes('Position', ...
                [data_left + width*(i_col-1) + phys_width + margin_intra_horiz/2, ...
                 data_top - (height*i_row - margin_inter_vert), ...
                 width - phys_width - margin_intra_horiz/2, ...
                 height - (margin_intra_vert + margin_inter_vert)/2]);
            set(gca, 'Box', 'off', 'XTick', [], 'YTick', []);
            axis equal;
        end
    end
end
