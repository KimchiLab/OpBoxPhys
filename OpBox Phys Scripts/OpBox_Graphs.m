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
    axes(subjects(i_subj).axis_time); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Format Time axis
    axis([0 num_sec_to_plot, subjects(i_subj).volt_range(1), subjects(i_subj).volt_range(end) + (subjects(i_subj).ch_offset * (subjects(i_subj).num_analog + subjects(i_subj).num_digital - 1))]);
    ylabel(sprintf('Box %d %s', subjects(i_subj).box, subjects(i_subj).name));
    subjects(i_subj).h_time_text = text(max(get(gca, 'XLim') * 0.99), max(get(gca, 'YLim')), datestr(0, 'dd HH:MM:SS')); % time = 0 at start
    set(subjects(i_subj).h_time_text, 'FontSize', font_size);
    set(subjects(i_subj).h_time_text, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top');
    % set(gca, 'XTick', 0:num_sec_to_plot); % Will not work as well with zooming in
    % Plot fake data
    temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_analog+subjects(i_subj).num_counter+subjects(i_subj).num_digital); % For 1 channel, ends up as multiple rows, 1 col; Counter gets plotted separately below, but leave here for now as other functions expect this count too unfortunately
    if subjects(i_subj).ch_offset > 0
        offsets = (0:(subjects(i_subj).num_analog + subjects(i_subj).num_counter + subjects(i_subj).num_digital - 1) * subjects(i_subj).ch_offset);
        temp_data = bsxfun(@plus, temp_data, offsets);
    end
    subjects(i_subj).h_plot_time = plot(temp_ts, temp_data, '-'); 
    % Draw line markers for second ticks/lines
    if num_sec_to_plot > 1
        h_line = line(repmat(1:num_sec_to_plot-1,2,1), repmat([subjects(i_subj).volt_range(1); subjects(i_subj).volt_range(end) + max(temp_data(:))],1,num_sec_to_plot-1));
        % set(h_line, 'LineWidth', 0.1, 'Color', [0 1 0]);
        set(h_line, 'LineWidth', 0.1, 'Color', repmat(0.7,1,3), 'LineStyle', ':');
    end
    % Flip order of data so later channels are underneath
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)) %Invert the order of the objects
    
    % Format Time axis: Counter sub-axis
    if (subjects(i_subj).num_counter > 0)
        yyaxis(gca, 'right'); % Added in Matlab R2016a+
        axis([0 num_sec_to_plot, -inf inf]);
        % Plot fake data
        temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_counter);
        subjects(i_subj).h_plot_counter = plot(temp_ts, temp_data, '-');
        set(gca, 'YTick', []); % Remove ticks and labels to speed up rescaling
    end
    yyaxis(gca, 'left'); % Switch back to main plot for all subsequent axes adjustments

    % Prep freq domain plot
    subjects(i_subj).axis_freq = axes_freq(i_subj);
    axes(subjects(i_subj).axis_freq); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Plot fake data
    temp_data = zeros(num_sec_to_plot * subjects(1).Fs, subjects(i_subj).num_analog);
    [freqs, dB_psd] = PowerSpecMatrix(temp_data, subjects(1).Fs, 2); % last number = desired_pts_per_hz (binning). Needs to be same in _Graphs & _DrawDataPowerEPs
%     [freqs, dB_psd] = PowerSpecMatrixWelch(temp_data, subjects(1).Fs, 2*subjects(1).Fs, 0.8);
    % [freqs, psdx, dB_psd] = PowerSpecDensity(temp_data, subjects(1).Fs, 0.5); % Uses ~3-4x processing power as binning. 0.5 = sig_smooth
    subjects(i_subj).h_plot_freq = plot(freqs, dB_psd);
%     set(subjects(i_subj).axis_freq, 'FontSize', font_size);
    max_freq_plot = 100;
    % max_freq_plot = subjects(1).Fs/2;
    axis([0 max_freq_plot, -60 -20]);
    set(gca, 'XMinorTick', 'on');
    set(gca, 'YGrid', 'on');
    % Flip order of data so later channels are underneath
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)) %Invert the order of the objects
    
    % Prep Evoked Potentials plot
    subjects(i_subj).axis_ep = axes_ep(i_subj);
    axes(subjects(i_subj).axis_ep); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    % Plot fake data
    temp_data = zeros(2*num_peri, subjects(i_subj).num_analog + subjects(i_subj).num_counter);
    subjects(i_subj).h_plot_ep = plot(((1:2*num_peri)-num_peri)/subjects(1).Fs*1e3, temp_data);
    axis([[(0-num_peri), num_peri]/subjects(1).Fs*1e3, subjects(i_subj).volt_range*0.1]);
    subjects(i_subj).h_n_peri = text(min(get(gca, 'XLim'))*0.85, max(get(gca, 'YLim'))*0.99,'0'); % n = 0 at start
    set(subjects(i_subj).h_n_peri, 'FontSize', font_size);
    set(subjects(i_subj).h_n_peri, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Top');
    subjects(i_subj).num_peri = num_peri;
    % Draw line marker for event time
    h_line = line([0 0], subjects(i_subj).volt_range);
    set(h_line, 'LineWidth', 0.1, 'Color', repmat(0.7,1,3), 'LineStyle', ':');
    % Flip order of data so later channels are underneath
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)) %Invert the order of the objects
    
    % Prep cam plot
    subjects(i_subj).axis_cam = axes_cam(i_subj);
    axes(subjects(i_subj).axis_cam); % matlab warns this is slow in a for loop, but necessary for axis adjustments and only run once here
    if ~isempty(subjects(i_subj).cam)
        % Add preview function
        vidRes = subjects(i_subj).cam.VideoResolution; 
        nBands = subjects(i_subj).cam.NumberOfBands; 
        subjects(i_subj).h_cam = image( zeros(vidRes(2), vidRes(1), nBands) ); 
        axis equal tight;
        preview(subjects(i_subj).cam, subjects(i_subj).h_cam);
    else
        set(gca, 'Visible', 'off');
    end
end

