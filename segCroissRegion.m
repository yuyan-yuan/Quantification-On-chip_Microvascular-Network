function [Phi_exterior, Phi,size_grown_region] = segCroissRegion(Igray, y, x)

    Phi = false(size(Igray, 1), size(Igray, 2));
    PhiOld = Phi;
    seedValue = Igray(round(y), round(x)); % Get the seed pixel value (0 or 1)
    Phi(round(y), round(x)) = true; % Initialize the region with the seed point
    fprintf('hi')
    while sum(Phi(:)) ~= sum(PhiOld(:)) %as long as size is still changing
        PhiOld = Phi;
        posVoisinsPhi = imdilate(Phi, strel('disk',1,0)) - Phi; % Find new neighbors
        voisins = find(posVoisinsPhi);%document location and value of neighbouring pixels
        valeursVoisins = Igray(voisins); %obtain value of neighbouring pixels
        
        % Include neighbors that match the seed pixel's value
        Phi(voisins(valeursVoisins == seedValue)) = true;
    end

    size_grown_region = nnz(Phi);
% Uncomment this if you only want to get the region boundaries
SE = strel('disk',1,0);
ImErd = imerode(Phi,SE);
Phi_exterior = Phi - ImErd;
end