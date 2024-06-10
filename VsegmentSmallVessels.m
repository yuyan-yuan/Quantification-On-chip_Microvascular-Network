function [clean_small_vessel, segmentedImg_small] = VsegmentSmallVessels(I, thresholds_small_vessel, thresholds_small_BW2)
    %Vectorized segmentation method
    % Determine the size of the image
    [rows, cols] = size(I);

    % Create a thresholds matrix for comparison
    T = repmat(thresholds_small_vessel, rows*cols, 1); %create a matrix as the size of image, containing thresholding value
    I_rep = repmat(I(:), 1, length(thresholds_small_vessel));% #of pixel=# of rows in T_rep, single colume vector

    % Generate masks
    lower_bound_mask = [true(rows*cols, 1), I_rep <= T(:, 1:end-1)];
    upper_bound_mask = [I_rep > T(:, 1:end-1), true(rows*cols, 1)];

    % Determine which range each pixel belongs to
    range_masks = lower_bound_mask & upper_bound_mask;
    [~, index] = max(range_masks, [], 2);  % Find the first true value in each row

    % Assign values based on the index
    values = 0:255/length(thresholds_small_vessel):255; %可疑
    segmentedImg_small = reshape(values(index), rows, cols);

    % Apply noise reduction using Wiener filter
    seg_rmnoise = wiener2(segmentedImg_small, [5 5]);

    % Repeat the thresholding process for the cleaned image
    % (You may repeat the same vectorization strategy or use simple thresholding if only one threshold is used)
    T_BW2 = repmat(thresholds_small_BW2, rows*cols, 1);
    seg_rmnoise_rep = repmat(seg_rmnoise(:), 1, length(thresholds_small_BW2));

    lower_bound_BW2 = [true(rows*cols, 1), seg_rmnoise_rep <= T_BW2(:, 1:end-1)];
    upper_bound_BW2 = [seg_rmnoise_rep > T_BW2(:, 1:end-1), true(rows*cols, 1)];

    range_masks_BW2 = lower_bound_BW2 & upper_bound_BW2;
    [~, index_BW2] = max(range_masks_BW2, [], 2);

    clean_small_vessel = reshape(values(index_BW2), rows, cols);
end
