function [db_spec, f, t, p, s] = SpecgramEEG(eeg, Fs, sec_win, sec_overlap)

if nargin < 4
    sec_overlap = 1;
    if nargin < 3
        sec_win = 2;
    end
end

% %% Filter EEG
% freq_lo = 0.5;
% freq_hi = 50;
% notch_flag = true;
% Fs = 1 / median(diff(ts));
% eeg = FilterEEG(data, Fs, freq_lo, freq_hi, notch_flag);

% %% Plot time domain
% ts = (1:numel(a))/Fs;
% plot(ts, eeg);
% axis([30 35, b.physmin b.physmax]);
% % axis([90 95, b.physmin b.physmax]);
% axis([1e4 + [0 10], -inf inf]);

%% Make Spectrograms
% tic;[~, f, t, p] = spectrogram(eeg, 4*Fs, 2*Fs, [], Fs);toc;
% tic;
[s, f, t, p] = spectrogram(eeg, round(sec_win * Fs), round(sec_overlap * Fs), [], Fs);
% toc;
db_spec = SpecDb(p);

