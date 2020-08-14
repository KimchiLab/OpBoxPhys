function [mean_data] = BinColAndMean(data, num_bins)

% data = 1:10;
% num_chans = 2;
% data = reshape(data, numel(data)/num_chans, num_chans);
% 
% num_bins = 10;

[num_rows, num_cols] = size(data);

num_rows_to_keep = floor(num_rows / num_bins) * num_bins;
if num_rows_to_keep < 1
    mean_data = mean(data, 1);
else
    crop_data = data(1:num_rows_to_keep, :);

    [num_rows, num_cols] = size(crop_data);

    shape_data = reshape(crop_data, num_bins, num_rows/num_bins, num_cols);
    mean_data = squeeze(mean(shape_data, 1));
end

% clf;
% hold on;
% plot(data, 'b.-');
% plot(mean_data, 'r.-');