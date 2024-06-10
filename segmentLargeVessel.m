function [clean_large_vessel, segmentedImg_large] = segmentLargeVessel(I,thresholds_large_vessel,thresholds_large_BW2)
    % Segment and clean image by thresholding and noise removal for large
    % vessels

    segmentedImg_large = zeros(size(I));
    clean_large_vessel = zeros(size(I));
    % Apply the thresholds for large vessels
    segmentedImg_large(I <= thresholds_large_vessel(1)) = 0; % First level
    for k = 2:length(thresholds_large_vessel)
        segmentedImg_large(I > thresholds_large_vessel(k-1) & I <= thresholds_large_vessel(k)) = 255; % Intermediate levels
    end
    segmentedImg_large(I > thresholds_large_vessel(end)) = length(thresholds_large_vessel) + 1; % Last level

    % Noise removal using Wiener filter
    seg_rmnoise_1_bright = wiener2(segmentedImg_large, [2 2]);
    seg_rmnoise_2_bright = wiener2(seg_rmnoise_1_bright, [5 5]);
    seg_rmnoise_3_bright = wiener2(seg_rmnoise_2_bright, [12 12]);

    % Redo binarification
    clean_large_vessel(seg_rmnoise_3_bright <= thresholds_large_BW2(1)) = 0; % First level
    for k = 2:length(thresholds_large_BW2)
        clean_large_vessel(seg_rmnoise_3_bright > thresholds_large_BW2(k-1) & seg_rmnoise_3_bright <= thresholds_large_BW2(k)) = 255; % Intermediate levels
    end
    clean_large_vessel(seg_rmnoise_3_bright > thresholds_large_BW2(end)) = 0; % Last level

end
