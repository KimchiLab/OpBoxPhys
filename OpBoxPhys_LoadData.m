% function [data] = OpBoxPhys_LoadData(filename_bin)
% Eyal Kimchi
% 2016/05/12
%
% .m file/function to load data from an OpBoxPhys .bin file
%
% Returns a data structure with following fields
% data.filename: Name of file (does not include directory)
% data.Fs: sampling frequency (e.g. 1000 for 1kHz)
% data.num_ch_analog: Number of analog channels
% data.num_ch_digital: Number of digital channels
% data.ts: Time stamps of each collected sample according to NI hardware timer/clock
% data.analog: Analog data (volts out) in matrix of analog channels x timestamps
% data.digital: Digital data (0 or 1) in matrix of digital channels x timestamps

function [data] = OpBoxPhys_LoadData(filename_bin, ch_crop_analog)

% tic;

% Identify date of file
% Filename format is Subject-Date-Time.bin
% Header changed after certain date?

% Load data
data.filename = filename_bin;
fid_bin = fopen(filename_bin,'r');
data.ver = fread(fid_bin,1,'int');
if data.ver == 3
    % Version 3 first used on 2018/07/05 for OpBoxPhysShare\ArchiveEncoder
    % Added ability to save rotary encoder data
    data.Fs = fread(fid_bin,1,'int');
    data.num_ch_analog = fread(fid_bin,1,'int');
    data.num_ch_counter = fread(fid_bin,1,'int');
    data.num_ch_digital = fread(fid_bin,1,'int');
elseif data.ver == 1000
    data.Fs = data.ver; % Early files had Fs as first number saved
    data.ver = -1;
    data.num_ch_analog = fread(fid_bin,1,'int');
    data.num_ch_digital = fread(fid_bin,1,'int');
    data.num_ch_counter = 0;
end

% Read in all and then separate, saves time?
all_data = fread(fid_bin,[1+(data.num_ch_analog + data.num_ch_counter + data.num_ch_digital),inf],'double'); % 1 for timestamps, then number of channels
fclose(fid_bin);
if isempty(all_data)
    data.ts = [];
    data.analog = [];
    data.counter = [];
    data.digital = [];
    fprintf('No data found in file %s (%.1f sec)\n\n', data.filename, toc);
else
    % Assign data to individual arrays
    data.ts = all_data(1,:);
    data.analog = all_data(1+(1:data.num_ch_analog), :);
    data.counter = all_data(1+data.num_ch_analog+(1:data.num_ch_counter), :);
    data.digital = logical(all_data(1+data.num_ch_analog+data.num_ch_counter + (1:data.num_ch_digital), :));
    clear all_data
    
    % identify possible start & end points of data: e.g. crop to behavioral session
    data.idx_start = 1;
    data.idx_end = numel(data.ts);

    % Look for crop markers in data
    num_win = round(0.098 * data.Fs); % Triggers should be approximately 100ms, so look for at least num_win in a row. Problem with early files that could have double start/stops
    num_win_max = round(0.102 * data.Fs);
    ch_start = [2 3]; % NP & Lick Triggers in freely moving. But StimOther & Lick for head fixed which is more problematic since co-occur. Also trial marker should be off
    ch_end = [2 4]; % NP & Fluid Triggers. But StimOther & Reinf for head fixed which is more problematic since co-occur. Also trial marker should be off
    % If there is digital data, search for possible start & stop signals
    if data.num_ch_digital
        % Try to find start and end of behavior
        if data.num_ch_digital >= max(ch_start)
            idx_start = find(data.digital(ch_start(1),:) & data.digital(ch_start(end),:));
            mask = conv(diff(idx_start), ones(num_win, 1), 'valid'); % looking for a near continuous block of TTLs
            idx_mask = find(mask == num_win) + num_win;
            data.idx_start = idx_start(idx_mask);
        end
        if data.num_ch_digital >= max(ch_end)
            idx_end = find(data.digital(ch_end(1),:) & data.digital(ch_end(end),:));
            mask = conv(diff(idx_end), ones(num_win, 1), 'valid'); % looking for a continuous block of TTLs
            idx_mask = find(mask == num_win) + num_win;
            data.idx_end = idx_end(idx_mask);
        end
    % If there is analog trial data, search for possible start & stop signals    
    elseif exist('ch_crop_analog', 'var') && ch_crop_analog > 0 && ch_crop_analog <= data.num_ch_analog
        num_events_beh = 5; % Number of event types multiplexed on this channel
        ch_trial = num_events_beh;
        mask_data = DiscHeadFixParseVoltBeh(data.analog(ch_crop_analog, :), num_events_beh)';
        num_win = round(0.05 * data.Fs); % Triggers should be approximately 100ms, so look for at least num_win in a row. Problem with early files that could have double start/stops
        num_win_max = round(0.102 * data.Fs);
        
        mask_start = mask_data(ch_start(1),:) & mask_data(ch_start(end),:) & ~mask_data(ch_trial,:);
        [idx_on, idx_off] = MaskToBouts(mask_start, 2, num_win, num_win_max);
        if ~isempty(idx_on)
            data.idx_start = idx_on;
        end

        mask_end = mask_data(ch_end(1),:) & mask_data(ch_end(end),:) & ~mask_data(ch_trial,:);
        [idx_on, idx_off] = MaskToBouts(mask_end, 2, num_win, num_win_max);
        if ~isempty(idx_off)
            data.idx_end = idx_off;
        end
    end
    
    if numel(data.idx_start) < 1
        fprintf('No start triggers found\n');
    end
    if numel(data.idx_end) < 1
        fprintf('No end triggers found\n');
    end
    if numel(data.idx_start) > 1 || numel(data.idx_end) > 1
        % take the largest window using outermost starts and ends
        fprintf('More than 1 phys file behavioral window. Adjust code to take largest\n');
        
        % If extra ends/starts? 
        % Add in presumed starts/ends at beginning/end of file vs. exclusions?
        % Exclude all ends before first start
        % Exclude all starts after last end
        % For a run of starts: only keep first
        % For a run of ends: only keep last
        bins = [data.idx_start(:); data.idx_end(:)];
        labels = ['S' * ones(size(data.idx_start(:))); 'E' * ones(size(data.idx_end(:)))];
        [sort_val, sort_idx] = sort(bins);
        sort_labels = labels(sort_idx);
        first_start = find(sort_labels == 'S', 1, 'first');
        last_end = find(sort_labels == 'E', 1, 'last');
        mask_sort = true(size(sort_labels));
        mask_sort(1:first_start-1) = false;
        mask_sort(last_end+1:end) = false;
        for i_sort = 2:numel(mask_sort)
            if sort_labels(i_sort) == 'S' && sort_labels(i_sort - 1) == 'S'
                mask_sort(i_sort) = false;
            end
        end
        for i_sort = 1:numel(mask_sort)-1
            if sort_labels(i_sort) == 'E' && sort_labels(i_sort + 1) == 'E'
                mask_sort(i_sort) = false;
            end
        end
        data.idx_start = sort_val(mask_sort & sort_labels == 'S');
        data.idx_end = sort_val(mask_sort & sort_labels == 'E');
        
%         %%% Prior draft code: assumed no overlaps/duplicates
%         temp_start = [data.idx_start(:); inf];
%         mask_start = true(size(data.idx_start));
%         mask_end = true(size(data.idx_end));
%         % For each start: X out all additional starts before next end
%         for i_start = 1:numel(data.idx_start)
%             idx_end = find(temp_start(i_start) < data.idx_end & data.idx_end < temp_start(i_start + 1), 1, 'last');
%             if ~isempty(idx_end)
%                 mask_start(i_start) = true;
%                 mask_end(idx_end) = true;
%             end
%         end
%         data.idx_start = data.idx_start(mask_start);
%         data.idx_end = data.idx_end(mask_end);
    
%         % Take last window 
%         data.idx_start = data.idx_start(end);
%         data.idx_end = data.idx_end(end);

        % Take longest window 
        dur_data = data.idx_end - data.idx_start;
        [~, idx_max] = max(dur_data);
        data.idx_start = data.idx_start(idx_max);
        data.idx_end = data.idx_end(idx_max);
    end
    
    % Prior exclusions by first or last windows
%         data.idx_start = data.idx_start(1); % Currently end of first window
% %                 % take the end of the first window
% %                 data.idx_start = idx_start(1);
% %                 if str2double(data.filename(5:12)) >= 20150227
% %                     data.idx_start = idx_start(end); % starts at end of last window
% %                 else
% %                     data.idx_start = idx_start(1); % prior to above date could have multiple starts, only first was valid
% %                 end
% %             else
% %                 data.idx_start = NaN;
%     end
%     if numel(data.idx_end) > 1
%         % take the end of the last window
%         data.idx_end = idx_end(data.end);
% %                 if str2double(data.filename(5:12)) >= 20150227
% %                     data.idx_end = idx_end(end); % starts at end of last window
% %                 else
% %                     data.idx_end = idx_end(1); % prior to above date could have multiple starts, only first was valid
% %                 end
% %             else
% %                 data.idx_end = NaN;
%     end

    % Crop data using identified start & end
    data.ts = data.ts(data.idx_start:data.idx_end);
    data.analog = data.analog(:, data.idx_start:data.idx_end);
    data.counter = data.counter(:, data.idx_start:data.idx_end);
    data.digital = data.digital(:, data.idx_start:data.idx_end);
    
    % Subtract mean from each channel
    data.analog = data.analog - repmat(mean(data.analog,2), 1, size(data.analog,2));

    % Zero & Unwrap counter data?
    num_bit = 32;
    mask_large = data.counter > 2^(num_bit-1);
    data.counter(mask_large) = data.counter(mask_large) - 2^num_bit;
    if ~isempty(data.counter)
        data.counter = data.counter - data.counter(1);  % Rezero start, since numbers primarily have relative value. But do this after accouting for rollover for negative numbers
    end
    % Counter stored as position, consider conversion to velocity: easy to do later
    % relative (diff pos / time) or absolute (convert to cm/s)
    
%     % Add interhemispheric differential lead: Superfluous in early analysis
%     if size(data.analog,1)>1
%         data.analog = [data.analog; data.analog(1,:) - data.analog(2,:)];
%         data.num_ch_analog = data.num_ch_analog + 1;
%     end

%     fprintf('Loaded phys data from %s (%.1f sec)\n', data.filename, toc);
end

% % Read in each type of data, saves memory?
% frewind(fid_bin);
% data.ts = fread(fid_bin,[1,inf],'double',data.num_ch_analog);
% data.ts = fread(fid_bin,[1,inf],'double',data.num_ch_analog+data.num_ch_digital); % 1 for timestamps, then number of channels
% fclose(fid_bin);

