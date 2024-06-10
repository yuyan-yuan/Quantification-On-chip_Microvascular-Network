function [clean_small_vessel, segmentedImg_small] = segmentSmallVessels(I, thresholds_small_vessel, thresholds_small_BW2)
    % Function to segment and clean images focusing on small vessels
    % using thresholding and multiple rounds of noise reduction.

    % Initialize output images
    segmentedImg_small = zeros(size(I)); % Assuming I is a grayscale image
    clean_small_vessel = zeros(size(I)); % Initialize the clean image

    % Apply the thresholds for small vessels
    segmentedImg_small(I <= thresholds_small_vessel(1)) = 0; % First level
    for k = 2:length(thresholds_small_vessel)
        segmentedImg_small(I > thresholds_small_vessel(k-1) & I <= thresholds_small_vessel(k)) = 255;
    end
    segmentedImg_small(I > thresholds_small_vessel(end)) = 0; % Last level
    
    % Optionally display the segmented image
    %imshow(segmentedImg_small, []);

    % Noise reduction using Wiener filter
    seg_rmnoise_1 = wiener2(segmentedImg_small, [15 15]);
    seg_rmnoise_2 = wiener2(seg_rmnoise_1, [7 7]);
    seg_rmnoise_3 = wiener2(seg_rmnoise_2, [2 2]);

    % Redo binarification based on noise reduced data
    clean_small_vessel(seg_rmnoise_3 <= thresholds_small_BW2(1)) = 0; % First level
    for k = 2:length(thresholds_small_BW2)
        clean_small_vessel(seg_rmnoise_3 > thresholds_small_BW2(k-1) & seg_rmnoise_3 <= thresholds_small_BW2(k)) = 255;
    end
    clean_small_vessel(seg_rmnoise_3 > thresholds_small_BW2(end)) = 0; % Last level

end
