function subjects = OpBox_Graphs(subjects)

% Prep plots: Settings to plot data in "real-time"
num_subj = numel(subjects);
if num_subj < 1
    return;
end

num_sec_to_plot = 5; % for time domain plots
num_peri = ceil(0.5 * subjects(1).Fs);
% peri_start = ceil(-0.5 * subjects(1).Fs); % for eps: peri time in sec * rate
% peri_end = ceil(0.5 * subjects(1).Fs); % for eps: peri time in sec * rate
font_size = 8;

[axes_time, axes_freq, axes_ep, axes_cam, figures] = OpBox_Axes(num_subj);
set(figures(1), 'Name', 'OpBox')
temp_ts = (1:subjects(1).Fs*num_sec_to_plot)/subjects(1).Fs; % in sec. Ends up as 1 rol, multiple cols

for i_subj = 1:num_subj
    % Prep time domain plot
    subjects(i_subj).axis_time = axes_time(i_subj);
    % axes(subjects(i_subj).axis_time); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Format Time axis
    axis(subjects(i_subj).axis_time, [0 num_sec_to_plot, subjects(i_subj).volt_range(1), subjects(i_subj).volt_range(end) + (subjects(i_subj).ch_offset * (subjects(i_subj).num_analog + subjects(i_subj).num_digital - 1))]);
    ylabel(subjects(i_subj).axis_time, sprintf('Box %d %s', subjects(i_subj).box, subjects(i_subj).name));
    % subjects(i_subj).h_time_text = text(subjects(i_subj).axis_time, max(get(subjects(i_subj).axis_time, 'XLim') * 0.99), max(get(subjects(i_subj).axis_time, 'YLim')), datestr(0, 'dd HH:MM:SS')); % time = 0 at start
    subjects(i_subj).h_time_text = text(subjects(i_subj).axis_time, max(get(subjects(i_subj).axis_time, 'XLim') * 0.99), max(get(subjects(i_subj).axis_time, 'YLim')), string(seconds(0), 'dd:hh:mm:ss')); % time = 0 at start
    set(subjects(i_subj).h_time_text, 'FontSize', font_size);
    set(subjects(i_subj).h_time_text, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top');
    % Plot fake data
    temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_analog+subjects(i_subj).num_counter+subjects(i_subj).num_digital); % For 1 channel, ends up as multiple rows, 1 col; Counter gets plotted separately below, but leave here for now as other functions expect this count too unfortunately
    if subjects(i_subj).ch_offset > 0
        offsets = (0:(subjects(i_subj).num_analog + subjects(i_subj).num_counter + subjects(i_subj).num_digital - 1) * subjects(i_subj).ch_offset);
        temp_data = bsxfun(@plus, temp_data, offsets);
    end
    subjects(i_subj).h_plot_time = plot(subjects(i_subj).axis_time, temp_ts, temp_data, '-'); 
    % Draw line markers for second ticks/lines
    if num_sec_to_plot > 1
        h_line = plot(subjects(i_subj).axis_time, repmat(1:num_sec_to_plot-1,2,1), repmat([subjects(i_subj).volt_range(1); subjects(i_subj).volt_range(end) + max(temp_data(:))],1,num_sec_to_plot-1));
        set(h_line, 'LineWidth', 0.1, 'Color', repmat(0.7,1,3), 'LineStyle', ':');
    end
    % Flip order of data so later channels are underneath
    c=get(subjects(i_subj).axis_time, 'Children'); %Get the handles for the child objects from the current axes
    set(subjects(i_subj).axis_time, 'Children',flipud(c)) %Invert the order of the objects
    
    % Format Time axis: Counter sub-axis
    if (subjects(i_subj).num_counter > 0)
        yyaxis(subjects(i_subj).axis_time, 'right'); % Added in Matlab R2016a+
        axis(subjects(i_subj).axis_time, [0 num_sec_to_plot, -inf inf]);
        % Plot fake data
        temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_counter);
        subjects(i_subj).h_plot_counter = plot(subjects(i_subj).axis_time, temp_ts, temp_data, '-');
        set(subjects(i_subj).axis_time, 'YTick', []); % Remove ticks and labels to speed up rescaling
        yyaxis(subjects(i_subj).axis_time, 'left'); % Switch back to main plot for all subsequent axes adjustments
    end

    % Prep freq domain plot
    subjects(i_subj).axis_freq = axes_freq(i_subj);
    % axes(subjects(i_subj).axis_freq); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Plot fake data
    temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_analog);
    [freqs, dB_psd] = PowerSpecMatrix(temp_data, subjects(1).Fs, 2); % last number = desired_pts_per_hz (binning). Needs to be same in _Graphs & _DrawDataPowerEPs
%     [freqs, dB_psd] = PowerSpecMatrixWelch(temp_data, subjects(1).Fs, 2*subjects(1).Fs, 0.8);
    % [freqs, psdx, dB_psd] = PowerSpecDensity(temp_data, subjects(1).Fs, 0.5); % Uses ~3-4x processing power as binning. 0.5 = sig_smooth
    subjects(i_subj).h_plot_freq = plot(subjects(i_subj).axis_freq, freqs, dB_psd);
%     set(subjects(i_subj).axis_freq, 'FontSize', font_size);
    max_freq_plot = 100;
    % max_freq_plot = subjects(1).Fs/2;
    axis(subjects(i_subj).axis_freq, [0 max_freq_plot, -60 -20]);
    set(subjects(i_subj).axis_freq, 'XMinorTick', 'on');
    set(subjects(i_subj).axis_freq, 'YGrid', 'on');
    % Flip order of data so later channels are underneath
    c=get(subjects(i_subj).axis_freq,'Children'); %Get the handles for the child objects from the current axes
    set(subjects(i_subj).axis_freq,'Children',flipud(c)) %Invert the order of the objects
    
    % Prep Evoked Potentials plot
    subjects(i_subj).axis_ep = axes_ep(i_subj);
    % axes(subjects(i_subj).axis_ep); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Plot fake data
    temp_data = zeros(2*num_peri, subjects(i_subj).num_analog + subjects(i_subj).num_counter);
    subjects(i_subj).h_plot_ep = plot(subjects(i_subj).axis_ep, ((1:2*num_peri)-num_peri)/subjects(1).Fs*1e3, temp_data);
    axis(subjects(i_subj).axis_ep, [[(0-num_peri), num_peri]/subjects(1).Fs*1e3, subjects(i_subj).volt_range*0.1]);
    subjects(i_subj).h_n_peri = text(subjects(i_subj).axis_ep, min(get(subjects(i_subj).axis_ep, 'XLim'))*0.85, max(get(subjects(i_subj).axis_ep, 'YLim'))*0.99,'0'); % n = 0 at start
    set(subjects(i_subj).h_n_peri, 'FontSize', font_size);
    set(subjects(i_subj).h_n_peri, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Top');
    subjects(i_subj).num_peri = num_peri;
    % Draw line marker for event time
    h_line = plot(subjects(i_subj).axis_ep, [0 0], subjects(i_subj).volt_range);
    set(h_line, 'LineWidth', 0.1, 'Color', repmat(0.7,1,3), 'LineStyle', ':');
    % Flip order of data so later channels are underneath
    c=get(subjects(i_subj).axis_ep,'Children'); %Get the handles for the child objects from the current axes
    set(subjects(i_subj).axis_ep,'Children',flipud(c)) %Invert the order of the objects
    
    % Prep cam plot: turned off for now
    subjects(i_subj).axis_cam = axes_cam(i_subj);
    % axes(subjects(i_subj).axis_cam); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    if numel(subjects(i_subj).cam_str)
        subjects(i_subj).h_cam = image(subjects(i_subj).axis_cam, subjects(i_subj).curr_frame); 
        axis(subjects(i_subj).axis_cam, 'equal', 'tight');
        set(subjects(i_subj).axis_cam, 'Box', 'off', 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
        colormap(subjects(i_subj).axis_cam, 'gray');
        % % Add preview function
        % vidRes = subjects(i_subj).cam.VideoResolution; 
        % nBands = subjects(i_subj).cam.NumberOfBands; 
        % subjects(i_subj).h_cam = image(subjects(i_subj).axis_cam, zeros(vidRes(2), vidRes(1), nBands) ); 
        % axis(subjects(i_subj).axis_cam, 'equal', 'tight');
        % try
        %     preview(subjects(i_subj).cam, subjects(i_subj).h_cam);
        % catch
        %     fprintf('Can not preview camera for subject %d!!!\n', i_subj);
        % end
    else
        set(subjects(i_subj).axis_cam, 'Visible', 'off');
    end
end

