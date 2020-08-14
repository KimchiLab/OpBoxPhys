% function [data] = OpBox_LoadPhysData(filename_bin, ch_crop_analog)
% Eyal Kimchi
% 2016/05/12
%
% .m file/function to load data from an OpBoxPhys .bin file
% Filename format is Subject-Date-Time.bin
% ch_crop_analog: Analog channel in which to look for cropping signals
%
% Returns a data structure with following fields (at least as of version 3 file)
% data.filename: Name of file (does not include directory)
% data.Fs: sampling frequency (e.g. 1000 for 1kHz)
% data.num_ch_analog: Number of analog channels
% data.num_ch_digital: Number of digital channels
% data.num_ch_counter: Number of counter channels
% data.ts: Time stamps of each collected sample according to NI hardware timer/clock
% data.analog: Analog data (volts out) in matrix of analog channels x timestamps
% data.digital: Digital data (0 or 1) in matrix of digital channels x timestamps
% data.counter: Counter data (e.g. position for treadmill) in matrix of counter channels x timestamps
%
% Version updates:
% Version 3 OpBox binary files includes the ability to load counter data, e.g. position from treadmill
%
% 2020/08/06 Load camera synch data if present

function [data] = OpBox_LoadPhysData(filename_bin, ch_crop_analog)

if nargin < 2
    ch_crop_analog = [];
end

% Load data
if numel(filename_bin) < 4 || ~strcmp(filename_bin(end-3:end), '.bin')
    filename_bin = [filename_bin '.bin'];
end
data.filename = filename_bin;
fid_bin = fopen(filename_bin,'r');
data.ver = fread(fid_bin,1,'int');

% Separate out header info based on .bin file version
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

% Read in all and then separate, saves disk time at expense of memory
all_data = fread(fid_bin,[1+(data.num_ch_analog + data.num_ch_counter + data.num_ch_digital),inf],'double'); % Each time slace has 1 datapoint for timestamps, then number of channels
fclose(fid_bin); % Close access to file
if isempty(all_data)
    data.ts = [];
    data.analog = [];
    data.counter = [];
    data.digital = [];
    fprintf('No data found in file %s\n\n', data.filename);
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
    % This is most helpful to remove DC offsets from EEG/phys recordings
    % Not as helpful for data that is 0-5V, e.g. multiplexed analog behavioral data
    data.analog = data.analog - repmat(mean(data.analog,2), 1, size(data.analog,2));
    
    % Unwrap and zero out counter data: Upper half of bit range are more easily considered to be "negative" numbers
    num_bit = 32;
    mask_large = data.counter > 2^(num_bit-1);
    data.counter(mask_large) = data.counter(mask_large) - 2^num_bit;
    % Rezero start, since numbers primarily have relative value. But do this after accouting for rollover for negative numbers
    if ~isempty(data.counter)
        data.counter = data.counter - data.counter(1);
    end
    % Counter data is stored as position, consider conversion to velocity: easy to do later either as relative (diff pos / time) or absolute (convert to cm/s) if calibration is known
    
    %     % Add interhemispheric differential EEG lead: Superfluous in early analysis
    %     if size(data.analog,1)>1
    %         data.analog = [data.analog; data.analog(1,:) - data.analog(2,:)];
    %         data.num_ch_analog = data.num_ch_analog + 1;
    %     end
    
    %     fprintf('Loaded phys data from %s (%.1f sec)\n', data.filename, toc);
end

%% Check if there is a OpBox Cam Synch file
filename_ocs = [filename_bin(1:end-4) '.ocs'];
if exist(filename_ocs, 'file')
    fid_ocs = fopen(filename_ocs, 'r');
    data.ver_camsynch = fread(fid_ocs,1,'int');
    
    % File Version Number: Version 1 as of 2020/08/12
    % File is just a paired list of numbers: NI timestamps acquired and Camera frames acquired
    % collected each time data from NI is collected
    if data.ver_camsynch == 1
        temp_data = fread(fid_ocs, 'double');
        data.camsynch = reshape(temp_data, [2, numel(temp_data)/2])';
    end
    fclose(fid_ocs); % Close access to file
    
    % Assign/Interpolate a timepoint for every frame based on interpolation
    num_frames = data.camsynch(end, 2);
    idx_new_frames = find(diff(data.camsynch(:, 2))>0) + 1;
    
    % Genearte new time series
    data.ts_frame = nan(1, num_frames);
    data.ts_frame(data.camsynch(idx_new_frames, 2)) = data.camsynch(idx_new_frames, 1);
    
    % Interpolate missing frame timestamps
    mask_nan = isnan(data.ts_frame);
    idx    = 1:numel(data.ts_frame);
    data.ts_frame(mask_nan) = interp1(idx(~mask_nan), data.ts_frame(~mask_nan), idx(mask_nan));
end
