% function OpBoxPhys_CropData
% Eyal Kimchi

function [data] = OpBoxPhys_CropData(data, ch_crop_analog)

% Look for crop markers in data
ch_start = [2 3]; % NP & Lick Triggers in freely moving. But StimOther & Lick for head fixed which is more problematic since can co-occur. But also trial marker should be off
ch_end = [2 4]; % NP & Fluid Triggers. But StimOther & Reinf for head fixed which is more problematic since can co-occur. But also trial marker should be off
% If there is digital data, search for possible start & stop signals
if data.num_ch_digital
    num_win = round(0.098 * data.Fs); % Triggers should be approximately 100ms, so look for at least num_win in a row. Problem with early files that could have double start/stops
    num_win_max = round(0.102 * data.Fs);
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
elseif exist('ch_crop_analog', 'var') && ~isempty(ch_crop_analog) && ch_crop_analog > 0 && ch_crop_analog <= data.num_ch_analog
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

% Crop based on what is found for start and end
if numel(data.idx_start) < 1
    fprintf('No start triggers found\n');
end
if numel(data.idx_end) < 1
    fprintf('No end triggers found\n');
end
if numel(data.idx_start) > 1 || numel(data.idx_end) > 1
    % take the largest window using outermost starts and ends
    fprintf('More than 1 phys file behavioral window. Adjusted to take largest\n');

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

    % Take longest window 
    dur_data = data.idx_end - data.idx_start;
    [~, idx_max] = max(dur_data);
    data.idx_start = data.idx_start(idx_max);
    data.idx_end = data.idx_end(idx_max);
end
% Make sure will be able to crop
if data.idx_start > data.idx_end
    fprintf('Crop start trigger %d found after end trigger %d! Resetting start to 1 in case missed beginning\n', data.idx_start, data.idx_end);
    data.idx_start = 1;
end

% Crop data using identified start & end
data.ts = data.ts(data.idx_start:data.idx_end);
data.analog = data.analog(:, data.idx_start:data.idx_end);
data.counter = data.counter(:, data.idx_start:data.idx_end);
data.digital = data.digital(:, data.idx_start:data.idx_end);
