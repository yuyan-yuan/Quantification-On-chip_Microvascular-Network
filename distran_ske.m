function skeleton = distran_ske(binaryImage, displayFigures)
    % Ensure the image is binary
    if ~islogical(binaryImage)
        error('Input must be a binary image.');
    end

    % Compute the distance transform of the complement of the binary image
    distTransform = bwdist(~binaryImage);
    
    % Normalize the distance transform
    normalizedDist = distTransform / max(distTransform(:));
    
    % Threshold the distance transform to keep only significant ridges
    thresholdValue = 0.5;  % This value can be adjusted or made into a parameter
    thresholdedDist = normalizedDist > thresholdValue;

    % Thinning the distance-transform-based image to obtain the skeleton
    thinSkeleton = bwmorph(thresholdedDist, 'thin', inf);

    % Remove small spurs from the skeleton
    skeleton = bwmorph(thinSkeleton, 'spur', inf);

    % Optionally display the results
    if nargin < 2 || displayFigures
        figure;
        subplot(1, 4, 1);
        imshow(binaryImage);
        title('Binary Image');

        subplot(1, 4, 2);
        imshow(distTransform, []);
        title('Distance Transform');
        colormap(jet);  % Apply the jet colormap
        colorbar;       % Optional: Add a colorbar to indicate the scale of values

        subplot(1, 4, 3);
        imshow(thresholdedDist);
        title('Thresholded Dist Transform');

        subplot(1, 4, 4);
        imshow(skeleton);
        title('Skeleton');
    end
end
