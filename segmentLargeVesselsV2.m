function [clean_large_vessel, segmentedImg_large] = segmentLargeVessels(I, thresholds_large_vessel, thresholds_large_BW2)
    % Function to segment and clean images focusing on small vessels
    % using thresholding and multiple rounds of noise reduction.

    % Apply the thresholds for small vessels
    segmentedImg_large(I <= thresholds_large_vessel(1)) = 1; % First level
    for k = 2:length(thresholds_large_vessel)
        segmentedImg_large(I > thresholds_large_vessel(k-1) & I <= thresholds_large_vessel(k)) = 255;
    end
    segmentedImg_large(I > thresholds_large_vessel(end)) = length(thresholds_large_vessel) + 1; % Last level
    
    % Optionally display the segmented image
    %imshow(segmentedImg_small, []);

    % Noise reduction using Wiener filter
    seg_rmnoise_1 = wiener2(segmentedImg_large, [5 5]);
    seg_rmnoise_2 = wiener2(seg_rmnoise_1, [5 5]);
    seg_rmnoise_3 = wiener2(seg_rmnoise_2, [12 12]);

    % Redo binarification based on noise reduced data
    clean_large_vessel(seg_rmnoise_3 <= thresholds_large_BW2(1)) = 1; % First level
    for k = 2:length(thresholds_large_BW2)
        clean_large_vessel(seg_rmnoise_3 > thresholds_large_BW2(k-1) & seg_rmnoise_3 <= thresholds_large_BW2(k)) = k;
    end
    clean_large_vessel(seg_rmnoise_3 > thresholds_large_BW2(end)) = length(thresholds_large_BW2) + 1; % Last level

end
