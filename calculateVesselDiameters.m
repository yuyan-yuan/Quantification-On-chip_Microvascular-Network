function diameterMap = calculateVesselDiameters(vascularMask, skeleton)
    % calculateVesselDiameters calculates and stores diameters at each skeleton pixel.
    % 
    % Inputs:
    %   vascularMask - Binary image (logical or uint8) where vessels are 1.
    %   skeleton - Logical array where the skeleton is 1.
    %
    % Output:
    %   diameterMap - Matrix of the same size as 'vascularMask' where the diameters 
    %                 are stored at skeleton points and zero elsewhere.

    % Validate input arguments and ensure they are the same size
    if ~isequal(size(vascularMask), size(skeleton))
        error('Vascular mask and skeleton must be of the same size.');
    end

    % Invert the vascular mask to calculate distance to nearest background
    invMask = ~vascularMask;

    % Compute the distance transform from the inverse mask
    distTransform = bwdist(invMask);

    % Calculate diameters by multiplying distances by 2 at skeleton locations
    diameters = 2 * distTransform .* skeleton;

    % Prepare the output matrix where diameters are stored only at skeleton points
    diameterMap = zeros(size(vascularMask));
    diameterMap(skeleton) = diameters(skeleton);
    diameterMap(diameterMap == 0) = NaN;
end
