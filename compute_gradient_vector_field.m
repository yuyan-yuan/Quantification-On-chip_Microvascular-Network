% Copyright Morteza Rezanejad
% McGill University, Montreal, QC 2018
%
% Contact: morteza [at] cim [dot] mcgill [dot] ca 
% -------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

function [D,IDX] = compute_gradient_vector_field(binaryImage)
%computes the gradient vector field of a binary image using the distance transform.

newBinaryImage = binaryImage;
outerBoundary = getOuterBoundary(binaryImage,0);%the bg color set to 0

size(outerBoundary);

for i = 1 : size(outerBoundary,1) % marks the outer boundary points in the new binary image.
    newBinaryImage(outerBoundary(i,1),outerBoundary(i,2)) = 1;
end

%computes the distance of every pixel to the boundary
[D2,IDX2] = bwdist(newBinaryImage);%D: distance to the nearest non-zero pixel; 
% IDX the linear index of the nearest non-zero pixel.
%inverts the binary picture, background are now non-zero
[D1,IDX1] = bwdist(~binaryImage);

IDX1(D1==0) = 0; %indices of bg pixels in binary image are set to zero
IDX2 (D2==0) = 0;

IDX = IDX1+IDX2;
for i = 1 : size(outerBoundary,1)
    IDX(outerBoundary(i,1),outerBoundary(i,2)) = sub2ind(size(IDX),outerBoundary(i,1),outerBoundary(i,2));
    %correct the 'combined' indexes
end

D = D1-D2; %the signed distance from each point to the nearest boundary; 'the gradient'
%this 'contious' decision on boudadry accurately calculate distances and indices from the foreground to the background. 

end