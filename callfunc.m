%calls functions and handle intermediate images for a single image
clc
clear
tic;  % Start timing
currentPath = pwd;

I = imread('clip2.tif');%ensure input are grayscale
[fileName, foldername] = createProcessedFolder('clip2'); %genrate folder
orig_fileName = sprintf('Original Image_%s.png', fileName);
fullPath_ori = fullfile(currentPath, foldername, orig_fileName);
imwrite(I,fullPath_ori);
I_gray = im2gray(I); %ensure picture format are in grayscale

%COLOR should be a 1-by-3 vector (% of Red, Green, Blue respectively) of values in the range [0, 1].  [0 0 0]
%is black, and [1 1 1] is white.
color_skeleton = [1,0.807,0.2]; %FFCE33 orange
%color_skeleton = [1,0.498,0.3137]; %pink red
%Vessel_mask_color = [0.864, 0.9686, 0.651]; %#DAF7A6 milky peppermint green
Vessel_mask_color = [0.509, 0.8325, 0.9686];%babby blue
%Vessel_mask_color = [0.8, 0.8, 1]; %purple


%% Segment large vessel and small vessel; clean & combine 
% Define manual thresholds for small vessels
thresholds_small_vessel = [8, 60]; 
thresholds_small_BW2 = [90, 255]; %second threshold after noise removal

%segment out small vessels
[clean_small_vessel, segmentedImg_small] = segmentSmallVessels(I_gray,thresholds_small_vessel,thresholds_small_BW2);


%segment out large vessels

% Manual defined thresholds for large vessels
thresholds_large_vessel = [50, 255];
thresholds_large_BW2 = [100, 256];
[clean_large_vessel, segmentedImg_large] = segmentLargeVessel(I_gray,thresholds_large_vessel,thresholds_large_BW2);


%combine small&large vessels using OR gate

is255_large = (clean_large_vessel == 255);
is255_small = (clean_small_vessel == 255);
combined_vessel_logical = is255_large | is255_small; %logical format for further processing

disp('Vessel Segmentation finished');

%for saving as image
dim_fileName = sprintf('Segmented Dim Vessel_%s.png', fileName);
fullPath_dim = fullfile(currentPath, foldername, dim_fileName);
imwrite(segmentedImg_small,fullPath_dim);

dim_clean_fileName = sprintf('Cleaned Segmented Dim Vessel_%s.png', fileName);
fullPath_dim_clean = fullfile(currentPath, foldername, dim_clean_fileName);
imwrite(clean_small_vessel,fullPath_dim_clean);


Bright_fileName = sprintf('Segmented Bright Vessel_%s.png', fileName);
fullPath_Bright = fullfile(currentPath, foldername, Bright_fileName);
imwrite(segmentedImg_large,fullPath_Bright);

Bright_clean_fileName = sprintf('Cleaned Segmented Bright Vessel_%s.png', fileName);
fullPath_Bright_clean = fullfile(currentPath, foldername, Bright_clean_fileName);
imwrite(clean_large_vessel,fullPath_Bright_clean);


full_segmented_vessel = double(combined_vessel_logical);  % This converts logical true to 1 and false to 0
segVel_fileName = sprintf('Segmented_Vessel_%s.png', fileName);
saveAsPNG(full_segmented_vessel, segVel_fileName,currentPath,foldername);

%% Region grown to obtain full vessel mask
min_grown_area = 15000; %minimal number of pixels
size_grown_area = 0;
color = 'white'; % select the color of area intended for seeding the region grow
tic;
randomY = 0;
randomX = 0;
while size_grown_area <= min_grown_area %restrict the size of grown area to above min area
    [randomY, randomX] = findRandomColoredPixel(combined_vessel_logical, color); %generate random initiaion seed of assinged color
    [Vessel_mask_exterior, Vessel_mask,size_grown_area] = segCroissRegion(combined_vessel_logical,randomX,randomY); %performing region grow
end
vessel_area=size_grown_area;
disp('Region Grown finished');

Vessel_mask = bwmorph(Vessel_mask,"fill"); %hole filling for single pixels
reggrown_fileName = sprintf('Region Grown %s.png', fileName);
saveAsPNG(Vessel_mask, reggrown_fileName,currentPath,foldername); %perform data conversion and output file

elapsedTime = toc;  % Measure elapsed time
fprintf('Elapsed Time: %.3f seconds\n', elapsedTime); %print execuetion time

%% Incorporate region grown exterior to the orginal image by vectorized pixel replacement

%inputs: the vessel mask, the orginal image, the ideal mask color
Orginal_plus_mask = applyVesselMaskToImage(Vessel_mask_exterior, I, Vessel_mask_color);
segVel_On_Original_fileName = sprintf('Orginal image with Segmented Vessel as Exterior %s.png', fileName);
saveAsPNG(Orginal_plus_mask, segVel_On_Original_fileName,currentPath,foldername); %perform data conversion and output file

%% Skeletonization by AOF
skeleton_fileName = sprintf('Skeleton %s.png', fileName);
colorskeleton_fileName = sprintf('Color coded Skeleton %s.png', fileName);
ske_input_path =fullfile(currentPath, foldername, reggrown_fileName);
ske_output_path = fullfile(currentPath, foldername, colorskeleton_fileName);
skeleton = generate_skeletons(ske_input_path);

%%
%remove noises on skeleton
skeleton_enhanced_conn = bwmorph(skeleton,"bridge");%enhance low connectivity skeleton before noise removal
skeleton_clean = bwareaopen(skeleton, 10);%all connected components (objects) that have fewer than 10 pixels
%imshowpair(skeleton_enhanced_conn,skeleton_clean,'montage')

%change the double pixel skeleton to single pixel
singlepix_skeleton = bwmorph(skeleton_clean, 'thin', Inf);
%imshowpair(skeleton_clean,singlepix_skeleton,'montage')

Vessel_length=nnz(singlepix_skeleton);

saveAsPNG(skeleton_clean, skeleton_fileName,currentPath,foldername); 

origin_skeleton = imoverlay_old(Orginal_plus_mask, skeleton_clean, color_skeleton);
origin_skeleton_fileName = sprintf('Skeleton Overlied orginal image %s.png', fileName);
saveAsPNG(origin_skeleton, origin_skeleton_fileName,currentPath,foldername); 

segmented_skeleton = imoverlay_old(full_segmented_vessel, skeleton_clean, color_skeleton);
segmented_skeleton_fileName = sprintf('Skeleton Overlied on segmented vessel %s.png', fileName);
saveAsPNG(segmented_skeleton, segmented_skeleton_fileName ,currentPath,foldername); 


disp('Skeletonization finished');
elapsedTime = toc;  % Measure elapsed time
fprintf('Elapsed Time: %.3f seconds\n', elapsedTime); %print execuetion time

%% matrix computation

diameterMap = calculateVesselDiameters(Vessel_mask, singlepix_skeleton);

% Visualize the diameter map in a colorful scale with black background
figure;
imagesc(diameterMap);
% Modify the colormap to start with black
cm = jet;  % Use jet colormap or any other preference
cm = [[0 0 0]; cm];  % Prepend black to the colormap
colormap(cm);
colormap(cm);
colorbar;  % Show a color bar indicating the scale of diameters
caxis([min(diameterMap(:)) max(diameterMap(:))]); % Adjust color axis to use the full range of the data
colorbar; % Show a color bar indicating the scale of diameters
axis image; % Maintain the aspect ratio of the image
title('Vessel Diameters Visualization','FontSize',16);
exportgraphics(gcf, ske_output_path);


%% Display all segmentation images in a panel: 
% 1. origal image 
% 2. boundary of segmentetd vessel overlayed on original image 
% 3. skeleton 
% 4. overlay skeleton and original image


% Create a figure window
figure;
sgtitle('Fig 1. Step breakdown for vessel segmentation'); 

% Display the original image
subplot(2, 3, 1);
imshow(I, []); % Use [] to scale the display based on the minimum and maximum values in the matrix
title('Original Image');


% Display 'segmentedImg_small'
subplot(2, 3, 2);
imshow(segmentedImg_small, []);
title('Segmented Dim Vessel');

% Display 'clean_small_vessel'
subplot(2, 3, 3);
imshow(clean_small_vessel, []);
title('Cleaned Dim Vessel');

% Display 'segmentedImg_large'
subplot(2, 3, 4);
imshow(segmentedImg_large, []);
title('Segmented Bright Vessel');


% Display 'clean_large_vessel'
subplot(2, 3, 5);
imshow(clean_large_vessel, []);
title('Cleaned Bright Vessel');

% Display 'full_segmented_vessel' (assuming this is another variable you have)
subplot(2, 3, 6);
imshow(full_segmented_vessel, []);
title('Full Segmented Vessel');
