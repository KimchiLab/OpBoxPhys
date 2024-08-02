function OpBoxPhys_LogData(src, ~)
% Adapted from Matlab Log Data example 
% http://www.mathworks.com/help/daq/examples/log-analog-input-data-to-a-file-using-ni-devices.html
% Log time stamp and data values to data (write to data stream). 
% To write data "sequentially", transpose the matrix.
%
% Changes from original example code
% 1. Stream from multiple subjects/files "simultaneously" (loop over subjects)
% 2. Later mod (2015/04/09): Some flexibility in fid checking 
% allows for Start/Stop saves at different times for different subjects
% 3. Asynchronous subjects
% Main issue is that all channels needed to be started/stopped simultaneously, 
% even though subjects are started asynchronously 
% and files are sometimes unnecessarily big or subjects are added later
% FIDs can not be modified on the fly except by using a global variable
% Therefore will only check/process data from active subjects
% 
% 2018/06/28: Added support for counter/rotary encoder channels
% File version now marked as version 3 in PhysFilePrep
% Consider changing to single rather than double since wasted precision?
% But lost some time precision when converted prior timestamps from double to single
% Timestamps are helpful with multiple subjects--aligning across single NI session
%
% 2020/08/05: Added software "synchronization" for camera and NI data
% Save timestamp of data chunks acquired with corresponding # frames acquired
%
% 2024/07/09: Restart files after certain amount of time
% Updated to new MATLAB DAQ structure, rather than just NI session
% Combined with plot/drawing function

global subjects

% Load data
[new_y_data, new_timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
num_new_pts = size(new_y_data, 1); % Rows=Timestamps, Cols=Channels

for i_subj = 1:numel(subjects)
    % check whether fid for this subject is valid = open file for logging
    if subjects(i_subj).fid ~= -1
        % pull out data assigned to just this subject
        new_subj_data = new_y_data(:, subjects(i_subj).idx_chan);

        % then write to the specified file stream
        count = fwrite(subjects(i_subj).fid, [new_timestamps, new_subj_data]', 'double');
        subjects(i_subj).num_ts_written = subjects(i_subj).num_ts_written + count/subjects(i_subj).num_ch; % Really count of numbers written, not bytes, across all channels
        
        % If there is camera data, save the numbers of data timestamps and camera frames
        if numel(subjects(i_subj).cam_id) && numel(subjects(i_subj).cam) && (subjects(i_subj).fid_camsynch > -1)
            % Timestamp X corresponds to Camera Frame Y (pairs of doubles)
            fwrite(subjects(i_subj).fid_camsynch, [new_timestamps(end), subjects(i_subj).cam.FramesAcquired], 'double');
        end

        % if a data file size exceeds ts cutoff, flushdata and start recording new files
        if subjects(i_subj).num_ts_written >= subjects(i_subj).num_ts_cutoff
            % Close files phys files
            subjects(i_subj) = subjects(i_subj).FileClose();

            % Generate new/next filename
            subjects(i_subj) = subjects(i_subj).FileName();

            % Close & Reopen cam files
            if numel(subjects(i_subj).cam_id)
                stop(subjects(i_subj).cam);
                flushdata(subjects(i_subj).cam);
                
                % Make sure all data written
                while (subjects(i_subj).cam.FramesAcquired ~= subjects(i_subj).cam.DiskLoggerFrameCount) 
                    pause(0.01);
                end
                close(subjects(i_subj).cam.DiskLogger); % File gets shrunk/deleted if closed before video stopped

                % Camera related file restart
                set(new_subject.cam, 'LoggingMode', 'disk');
                vid_writer = VideoWriter(new_subject.filename, 'MPEG-4');  % Make sure this matches OpBoxPhys_LogData & OpBox_Add
                set(vid_writer, 'Quality', 50); % 0-100: lower quality/smaller file size, default 75
                set(subjects(i_subj).cam, 'DiskLogger', vid_writer); % Point DiskLogger to new video writer
                start(subjects(i_subj).cam);
            end

            % Physiology file starts writing as soon as there is an available fid, set up after camera
            subjects(i_subj) = subjects(i_subj).FilePrepPhys();
        end
        
        %% Plotting data
        if numel(subjects(i_subj).axis_time) % Make sure field exists
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
                if numel(subjects(i_subj).h_plot_counter)
                    % Currently only support 1 rotary encoder per box
                    subjects(i_subj).h_plot_counter.YData = y_data{subjects(i_subj).num_analog+1};
    %                 set(subjects(i_subj).h_plot_counter, {'ydata'}, y_data{subjects(i_subj).num_analog+1});
                end
            else % single channel of data
                y_data = [old_y_data(num_new_pts+1:end), new_y_data(:, subjects(i_subj).idx_chan)'];
                set(subjects(i_subj).h_plot_time, 'ydata', y_data);
            end
            if subjects(i_subj).ts_start < 0
                subjects(i_subj).ts_start = min(new_timestamps);
            end
            % set(subjects(i_subj).h_time_text, 'String', datestr((new_timestamps(end) - subjects(i_subj).ts_start)/86400, 'dd HH:MM:SS'));
            set(subjects(i_subj).h_time_text, 'String', string(seconds(new_timestamps(end) - subjects(i_subj).ts_start), 'dd:hh:mm:ss'));
    
            % Freq Domain graphs
            if iscell(y_data)
                data = vertcat(y_data{:})';
            else
                data = y_data(:);
            end
            % now restrict only to analog channels for this subject
            data_analog = data(:,1:subjects(i_subj).num_analog);
            [~, dB_psd] = PowerSpecMatrix(data_analog, src.Rate, 2); % last number = desired_pts_per_hz (binning). Needs to be same in _Graphs & _DrawDataPowerEPs 
            % [~, dB_psd] = PowerSpecMatrixWelch(data_analog, src.Rate, 2*src.Rate, 0.8);
    	    % [~, ~, dB_psd] = PowerSpecDensity(data, src.Rate, 0.5); % 0.5 = sig_smooth. Convolution smoothing takes about a little more than 2x binning
    
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
            if numel(subjects(i_subj).ch_trigger)
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
end


