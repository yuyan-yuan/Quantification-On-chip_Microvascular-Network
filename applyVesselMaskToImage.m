function oriImageRGB = applyVesselMaskToImage(Vessel_mask, Original_img, Vessel_mask_color)
    % Convert double to logical
    Vessel_mask = logical(Vessel_mask);

    % Prepare the colored mask using vectorized operations
    [rows, cols] = size(Vessel_mask);
    colored_mask = zeros(rows, cols, 3);
    for k = 1:3
        colored_mask(:,:,k) = double(Vessel_mask) * Vessel_mask_color(k);
    end

    % Ensure the original image is in double precision
    Original_img = im2double(Original_img);

    % Replicate the grayscale image across three channels
    oriImageRGB = repmat(Original_img, [1, 1, 3]);

    % Apply colored mask
    mask = any(colored_mask ~= 0, 3);  % Create a mask from non-zero entries
    for k = 1:3
        temp_channel = oriImageRGB(:,:,k);
        mask_channel = colored_mask(:,:,k);
        temp_channel(mask) = mask_channel(mask);
        oriImageRGB(:,:,k) = temp_channel;
    end
end
