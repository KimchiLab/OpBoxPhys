function OpBoxPhys_DrawData(src, event)

global subjects; % Use as global variable so that listener handles have access to up to date info

new_y_data = event.Data; % Variable contains data of all subjects
num_new_pts = size(new_y_data,1);

% Now go through by subject and combine with previous data
for i_subj = 1:numel(subjects)
    if ~isempty(subjects(i_subj).axis_time) % Make sure field exists
        % Time Domain graphs
        old_y_data = get(subjects(i_subj).h_plot_time, 'ydata');
        y_data = old_y_data; % simplifies preallocation warning which would otherwise show up for y_data{i_ch} below

        num_ch = numel(old_y_data); % num channels for just this subject
        if iscell(old_y_data)
            for i_ch = 1:num_ch
%                 y_data{i_ch} = [old_y_data{i_ch}(num_new_pts+1:end), new_y_data(:, subjects(i_subj).idx_chan(i_ch))'];
                % Separate out channels along y axis if desired
                new_ch_data = new_y_data(:, subjects(i_subj).idx_chan(i_ch))';
%                 new_ch_data = new_ch_data + (i_ch-1) * ones(size(new_ch_data));
                new_ch_data = new_ch_data + (i_ch-1) * subjects(i_subj).ch_offset * ones(size(new_ch_data));
%                 new_ch_data = new_ch_data + subjects(i_subj).ch_offset(i_ch) * ones(size(new_ch_data));
                y_data{i_ch} = [old_y_data{i_ch}(num_new_pts+1:end), new_ch_data];
            end
            set(subjects(i_subj).h_plot_time, {'ydata'}, y_data);
            % Time Domain graphs: Counter/Rotary Encoder Data
            if ~isempty(subjects(i_subj).h_plot_counter)
                % Currently only support 1 rotary encoder per box
                subjects(i_subj).h_plot_counter.YData = y_data{subjects(i_subj).num_analog+1};
%                 set(subjects(i_subj).h_plot_counter, {'ydata'}, y_data{subjects(i_subj).num_analog+1});
            end
        else % single channel of data
            y_data = [old_y_data(num_new_pts+1:end), new_y_data(:, subjects(i_subj).idx_chan)'];
            set(subjects(i_subj).h_plot_time, 'ydata', y_data);
        end
        if subjects(i_subj).ts_start < 0
            subjects(i_subj).ts_start = min(event.TimeStamps);
        end
        set(subjects(i_subj).h_time_text, 'String', datestr((event.TimeStamps(end) - subjects(i_subj).ts_start)/86400, 'dd HH:MM:SS'));

        % Freq Domain graphs
        if iscell(y_data)
            data = vertcat(y_data{:})';
        else
            data = y_data(:);
        end
        % now restrict only to analog channels for this subject
        data_analog = data(:,1:subjects(i_subj).num_analog);
        [~, dB_psd] = PowerSpecMatrix(data_analog, src.Rate, 2); % last number = desired_pts_per_hz (binning). Needs to be same in _Graphs & _DrawDataPowerEPs 
%         [~, dB_psd] = PowerSpecMatrixWelch(data_analog, src.Rate, 2*src.Rate, 0.8);
    %     [~, ~, dB_psd] = PowerSpecDensity(data, src.Rate, 0.5); % 0.5 = sig_smooth. Convolution smoothing takes about a little more than 2x binning

        if iscell(y_data)
            new_freq_y_data = cell(subjects(i_subj).num_analog, 1);
            for i_ch = 1:subjects(i_subj).num_analog
                new_freq_y_data{i_ch} = dB_psd(:, i_ch);
            end    
            set(subjects(i_subj).h_plot_freq, {'ydata'}, new_freq_y_data);
        else
            new_freq_y_data = dB_psd;
            set(subjects(i_subj).h_plot_freq, 'ydata', new_freq_y_data);
        end

        % Evoked potential graphs from first digital channel or last analog channel
        if ~isempty(subjects(i_subj).ch_trigger)
            % Look through new digital data in the window of interest and see if any new events
            data_event = data(:, subjects(i_subj).ch_trigger); % channel for thresholding/events is the first channel after analog chans
            idx_zero = numel(data_event) - subjects(i_subj).num_peri - num_new_pts; % have to back off the number of peri timepoints and num new points so that get full window if catch event
            win_data_event = data_event(idx_zero + (0:num_new_pts), :); % Look just at data that has newly moved into the window of interest.  0 rather than 1:num_new_pts so that get 1 previous point for diff operation
            idx_thresh = find(diff(win_data_event) >= subjects(i_subj).trigger_thresh); % Look for event onsets >= threshold (e.g. 1 is 0-1 step for digital, >1 is step for analog > 1 V)
            % idx_thresh = find(diff(win_data_event) >= ((subjects(i_subj).ch_trigger - 1) * subjects(i_subj).ch_offset) + subjects(i_subj).trigger_thresh); % Look for event onsets (==1 is step for digital, >1 is step for analog > 1 V)

            % Check if found any new events in this window
            new_n = numel(idx_thresh);
            if new_n > 0
                % Collect new EP data for each event
                new_peri_data = nan(subjects(i_subj).num_peri*2, size(data_analog, 2), new_n);
                for i_event = 1:new_n
                    idx_event = idx_zero + idx_thresh(i_event);
                    new_peri_data(:, :, i_event) = data_analog(idx_event-subjects(i_subj).num_peri + (1:subjects(i_subj).num_peri*2), :);
                end
                % subtract out mean response
                new_peri_data = new_peri_data - repmat(mean(new_peri_data, 1), [size(new_peri_data,1), 1, 1]);

                % Get old EP data and add the new one in a weighted manner
    %                 axis(subjects(i_subj).axis_ep);
                old_peri_data = get(subjects(i_subj).h_plot_ep, 'ydata');
                old_n = str2double(get(subjects(i_subj).h_n_peri, 'String'));
                y_data = old_peri_data; % simplifies preallocation warning which would otherwise show up for y_data{i_ch} below

                if iscell(old_peri_data)
                    for i_ch = 1:numel(old_peri_data)
                        y_data{i_ch} = old_peri_data{i_ch}(:).*old_n + sum(squeeze(new_peri_data(:, i_ch, :)),2);
                        y_data{i_ch} = y_data{i_ch} / (old_n + new_n);
                    end
                    set(subjects(i_subj).h_plot_ep, {'ydata'}, y_data);
                else % single channel of data
                    y_data = old_peri_data(:).*old_n + mean(squeeze(new_peri_data(:, 1, :)),2);
                    set(subjects(i_subj).h_plot_time, 'ydata', y_data);
                end
                set(subjects(i_subj).h_n_peri, 'String', sprintf('%d', old_n+new_n));
            end
        end
    end
end
