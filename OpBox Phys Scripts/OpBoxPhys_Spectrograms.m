function [f, t, p] = OpBoxPhys_Spectrograms(data)

% dur_win = 2^16; % ~1 min resolution = 65536 samples at 1k = 65.536 sec
% dur_win = 2^14; % ~16sec
% dur_win = 2^12; % ~4sec
% dur_win = 60; % 60 Hz noise frequency band gets too small with >= 30sec windows, visible at 10, but DC band somewhat compromised
% win_samples = 2^ceil(log2(dur_win * data.Fs));
% win_samples = 2^14; % ~16 sec, freq resolution = 0.0610 Hz
% frac_overlap = 0.5;
win_samples = 2^12; % ~4 sec, freq resolution = ~0.25 Hz
frac_overlap = 0.5;

num_samples = numel(data.ts);
if num_samples == 0
    fprintf('No samples for spectrogram\n');
    f = []; t = []; p = [];
    return;
elseif num_samples < win_samples
    fprintf('Not enough samples (%d) for window (%d) for spectrogram, using reduced set\n', num_samples, win_samples);
    win_samples = num_samples;
end

% tic;
for i_ch = 1:data.num_ch_analog
%     [s, f, t, p] = spectrogram(temp_data, win_samples, 0, [], data.Fs);
%     [~, f, t, p(:,:,i_ch)] = spectrogram(temp_data, win_samples, 0, [], data.Fs);
    [~, f, t, p(:,:,i_ch)] = spectrogram(data.analog(i_ch, :), win_samples, floor(win_samples*frac_overlap), [], data.Fs);
end
% toc