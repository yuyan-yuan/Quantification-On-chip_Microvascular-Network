function [randomX, randomY] = findRandomColoredPixel(image, color)
    % Ensure the image is logical
    if ~islogical(image)
        error('The input image must be a logical (binary) image.');
    end
    
    % Find pixels that match the color preference and collect them
    if strcmp(color, 'black')
        [rows, cols] = find(image == false);
    elseif strcmp(color, 'white')
        [rows, cols] = find(image == true);
    else
        error('Color preference must be ''black'' or ''white''.');
    end
    
    % Check if there are any pixels that match the preference
    if isempty(rows) || isempty(cols)
        error(['No pixels found matching the ', color, ' color preference.']);
    end
    
    % Select a random index from those pixels
    randomIndex = randi([1, length(rows)]);
    
    % Return the coordinates of the randomly selected pixel
    randomX = cols(randomIndex);
    randomY = rows(randomIndex);
end