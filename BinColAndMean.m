function [mean_data] = BinColAndMean(data, num_bins)

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
