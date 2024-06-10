clc
clear

% Create a 512x512 binary image with a black background
binaryImage = zeros(512, 512);

% Define the center and radius of the sphere
centerX = 256;
centerY = 256;
radius = 50; % Diameter is 100 pixels

% Create the sphere in the binary image
[x, y] = meshgrid(1:512, 1:512);
distanceFromCenter = sqrt((x - centerX).^2 + (y - centerY).^2);
binaryImage(distanceFromCenter <= radius) = 1;

% Display the original binary image
figure;
imshow(binaryImage);
title('Original Binary Image with White Sphere');

% Call the compute_gradient_vector_field function
[D, IDX, D1, D2] = compute_gradient_vector_field(binaryImage);

% Display the gradient vector field
figure;
imshow(D, []);
title('Gradient Vector Field D');
colorbar;
caxis([0, 50]); 

% % Display the combined index matrix
% figure;
% imshow(IDX, []);
% title('Combined Index Matrix');
% colorbar;
% caxis([0, 50]); 

% Display the D1 matrix
figure;
imshow(D1, []);
title('D1 Matrix');
colorbar;
caxis([0, 50]); 

% Display the D2 matrix
figure;
imshow(D2, []);
title('D2 Matrix');
colorbar;
caxis([0, 50]); 

function [result,result2] = getOuterBoundary(binaryImage,background)
    m_Neighbors8 = InitializeNeighborhoods();
    result2 = zeros(size(binaryImage));
    [m,n] = size(binaryImage);
    result = zeros(m*n,2);
    counter = 1;
    for i = 2 : m-1 
        for j = 2 : n-1        
            if(is_outer_border_point(binaryImage,i,j,m_Neighbors8,background))
                result(counter,:) = [i j];
                result2(i,j) = 1;
                counter = counter + 1;
            end        
        end
    end
    result = result(1:counter-1,:);
end

function m_Neighbors8 = InitializeNeighborhoods()
    m_Neighbors8 = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
end

function result2 = is_outer_border_point(binaryImage,ii,jj,m_Neighbors8,background)
    if(binaryImage(ii,jj)==background)
        result2 = 0;
        nOfBackgroundPoints = 0;
        nOfForegoundPoints = 0;
        iterator = 1;
        while( (nOfBackgroundPoints == 0 || nOfForegoundPoints == 0) && iterator <= 8 )
            if(binaryImage(ii+m_Neighbors8(iterator,1),jj+m_Neighbors8(iterator,2)) > background)
                nOfForegoundPoints = nOfForegoundPoints + 1;
            end
            if(binaryImage(ii+m_Neighbors8(iterator,1),jj+m_Neighbors8(iterator,2)) <= background)
                nOfBackgroundPoints = nOfBackgroundPoints + 1;
            end
            iterator = iterator + 1;
        end
        if nOfBackgroundPoints > 0 && nOfForegoundPoints > 0
            result2 = 1;
        end
    else
        result2 = 0;
    end
end

function [D,IDX,D1,D2] = compute_gradient_vector_field(binaryImage)
    newBinaryImage = binaryImage;
    outerBoundary = getOuterBoundary(binaryImage,0);
    for i = 1 : size(outerBoundary,1)
        newBinaryImage(outerBoundary(i,1),outerBoundary(i,2)) = 1;
    end
    [D2,IDX2] = bwdist(newBinaryImage);
    [D1,IDX1] = bwdist(~binaryImage);
    IDX1(D1==0) = 0;
    IDX2(D2==0) = 0;
    IDX = IDX1 + IDX2;
    for i = 1 : size(outerBoundary,1)
        IDX(outerBoundary(i,1),outerBoundary(i,2)) = sub2ind(size(IDX),outerBoundary(i,1),outerBoundary(i,2));
    end
    D = D1 - D2;
end
