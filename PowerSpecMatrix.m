% Data must be in columns as per FFT
function [freqs, dB_psd, psdx] = PowerSpecMatrix(data, Fs, desired_pts_per_hz)

% Fs = 1e3;
% data = randn(1*Fs, 5);
% clf;
% imagesc(data);
% plot(data);

if nargin < 3
    desired_pts_per_hz = NaN;
end

[N, num_ch] = size(data);

% Single periodogram based psd estimate
freqs = 0:Fs/N:Fs/2; % determine freq points
xdft = fft(data);
xdft = xdft(1:floor(N/2)+1, :);
psdx = (1/(Fs*N)).*abs(xdft).^2;
psdx(2:end-1, :) = 2*psdx(2:end-1, :);

if ~isnan(desired_pts_per_hz)
    current_pts_per_hz = length(freqs) / (Fs/2);
    num_bins = floor(current_pts_per_hz / desired_pts_per_hz);
    % num_bins = 100;
    % num_pts = length(freq);
    % dur_smooth = floor(pts_per_hz) * 2;
    % win_conv = ones(dur_smooth, 1)/dur_smooth;
    % y_vals = conv2(y_vals, win_conv, 'valid');
    % x_vals = conv(freq, win_conv, 'valid');

    if num_bins > 1
        psdx = BinColAndMean(psdx, num_bins);
        freqs = BinColAndMean(freqs(:), num_bins);
    end
end

% Take log of psdx (periodogram) for easier display
dB_psd = 10*log10(psdx);

% Plot output?
if nargout < 1
    plot(freqs, dB_psd); 
%     grid on;
    xlabel('Frequency (Hz)'); 
    ylabel('Power/Frequency (dB/Hz)');
end
