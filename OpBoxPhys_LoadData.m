% function [data] = OpBoxPhys_LoadData(filename_bin)
% Eyal Kimchi
% 2016/05/12
%
% .m file/function to load data from an OpBoxPhys .bin file
% Filename format is Subject-Date-Time.bin
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

% Load data
data.filename = filename_bin;
fid_bin = fopen(filename_bin,'r');
data.ver = fread(fid_bin,1,'int');
if data.ver == 1000
    data.Fs = data.ver; % Early files had Fs as first number saved, which was 1000 in all recordings then
    data.ver = -1;
    data.num_ch_analog = fread(fid_bin,1,'int');
    data.num_ch_digital = fread(fid_bin,1,'int');
    data.num_ch_counter = 0;
elseif data.ver == 3
    % Version 3 first used on 2018/07/05 for OpBoxPhysShare\ArchiveEncoder
    % Added ability to save rotary encoder data
    data.Fs = fread(fid_bin,1,'int');
    data.num_ch_analog = fread(fid_bin,1,'int');
    data.num_ch_counter = fread(fid_bin,1,'int');
    data.num_ch_digital = fread(fid_bin,1,'int');
end

% Read in all data and then separate, saves time if can fit in memory
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
    
    % Define possible start & end points of data: e.g. crop to behavioral session
    data.idx_start = 1;
    data.idx_end = numel(data.ts);
    data = OpBoxPhys_CropData(data, ch_crop_analog);
    
    % Subtract mean from each analog channel
    data.analog = data.analog - repmat(mean(data.analog,2), 1, size(data.analog,2));

    % Zero & Unwrap counter data
    num_bit = 32;
    mask_large = data.counter > 2^(num_bit-1);
    data.counter(mask_large) = data.counter(mask_large) - 2^num_bit;
    if ~isempty(data.counter)
        data.counter = data.counter - data.counter(1);  % Rezero start, since numbers primarily have relative value. But do this after accouting for rollover for negative numbers
    end
    % Counter data is stored as position, consider conversion to velocity: easy to do later
    % relative (diff pos / time) or absolute (convert to cm/s)
    
%     % Add interhemispheric differential lead: Superfluous in early analysis
%     if size(data.analog,1)>1
%         data.analog = [data.analog; data.analog(1,:) - data.analog(2,:)];
%         data.num_ch_analog = data.num_ch_analog + 1;
%     end

%     fprintf('Loaded phys data from %s (%.1f sec)\n', data.filename, toc);
end

% % Read in each type of data, saves memory, e.g.
% frewind(fid_bin);
% data.ts = fread(fid_bin,[1,inf],'double',data.num_ch_analog);
% data.ts = fread(fid_bin,[1,inf],'double',data.num_ch_analog+data.num_ch_digital); % 1 for timestamps, then number of channels
% fclose(fid_bin);

