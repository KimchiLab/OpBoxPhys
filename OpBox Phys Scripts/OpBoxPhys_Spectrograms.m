function [f_spec, ts_spec, p] = OpBoxPhys_Spectrograms(data)

% dur_win = 2^16; % ~1 min resolution = 65536 samples at 1k = 65.536 sec
% dur_win = 2^14; % ~16sec
% dur_win = 2^12; % ~4sec
% dur_win = 60; % 60 Hz noise frequency band gets too small with >= 30sec windows, visible at 10, but DC band somewhat compromised
% win_samples = 2^ceil(log2(dur_win * data.Fs));
% win_samples = 2^14; % ~16 sec, freq resolution = 0.0610 Hz
% frac_overlap = 0.5;
% win_samples = 2^12; % ~4 sec, freq resolution = ~0.25 Hz
% win_samples = 4 * data.Fs; % ~4 sec, freq resolution = ~0.25 Hz
% frac_overlap = 0.5;
sec_win_spec = 4;
sec_overlap = 2;

% num_samples = numel(data.ts);
% if num_samples == 0
%     fprintf('No samples for spectrogram\n');
%     f = []; t = []; p = [];
%     return;
% elseif num_samples < win_samples
%     fprintf('Not enough samples (%d) for window (%d) for spectrogram, using reduced set\n', num_samples, win_samples);
%     win_samples = num_samples;
% end

for i_ch = 1:data.num_ch_analog
%     [~, f, t, p(:,:,i_ch)] = spectrogram(data.analog(i_ch, :), win_samples, floor(win_samples*frac_overlap), [], data.Fs);
    [db_psd_raw(:, :, i_ch), f_spec, ts_spec, p(:, :, i_ch)] = SpecgramEEG(data.analog(i_ch, :), data.Fs, sec_win_spec, sec_overlap);
end

%% Plot results if no output arguments
boundaries = [0.05 0.99, 0.08 0.92];
margins = [0.1 0.02 0.1];
freq_lim = [0 65];
c_lim = [-65 -35];

if nargout == 0
    clf;
    ax = AxesGrid(size(db_psd_raw, ndims(db_psd_raw)), 1, boundaries, margins);
    dts_spec = datetime(ts_spec,'ConvertFrom','epochtime','Epoch',data.dts_start);
%     h = PlotSpecGram(t, f, p, ax);
    for i_ch = 1:size(db_psd_raw, ndims(db_psd_raw))
        PlotSpecGram(dts_spec, f_spec, squeeze(db_psd_raw(:, :, i_ch)), ax(i_ch)); % uses dts in R2022b, but not R2023b?!
        ylim(ax(i_ch), freq_lim);
        clim(ax(i_ch), c_lim)
    end
    title(ax(1), data.filename);
end
