function saveAsPNG(imageData, fileName, baseFolder, subFolder)
    % Function to save imageData to a PNG file, scaling it if necessary.
    % The image data can be in any numeric format and will be scaled to uint8.

    % Ensure the imageData is in the range 0 to 1
    % This line handles imageData that could be in formats other than double, e.g., uint8
    if ~isa(imageData, 'uint8')  % Check if imageData is not already uint8
        imageData = double(imageData);  % Convert imageData to double for processing
        imageData = max(0, min(1, imageData));  % Clip to [0, 1] to avoid any out-of-range values
    
        % Scale to 0-255 and convert to uint8
        imageData = uint8(255 * imageData);
    end

    % Create the full file path
    fullPath = fullfile(baseFolder, subFolder, fileName);

    % Check if the directory exists, create if it doesn't
    if ~exist(fullfile(baseFolder, subFolder), 'dir')
        mkdir(fullfile(baseFolder, subFolder));  % Creates the directory
        disp(['Directory ', fullfile(baseFolder, subFolder), ' created.']);
    end
    
    % Write to PNG file
    imwrite(imageData, fullPath);
    disp(['File ', fileName, ' saved successfully to ', fullPath]);
end
