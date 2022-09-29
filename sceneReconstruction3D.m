
% Structure from motion from two views
% https://www.mathworks.com/help/vision/ug/structure-from-motion-from-two-views.html

clc; clear; close

% Add relative paths of directories with images and 3D data
addpath('images\','3D_data\');

I1 = imread('Rh_Narpa_z750.png'); 
I2 = imread('Rh_Narpa_z800.png');
imshowpair(I1, I2, 'montage'); 
title('Original Images');
%%
intrinsics = cameraIntrinsics(933,[250 250],[500 500]);
I1 = undistortImage(I1, intrinsics);
I2 = undistortImage(I2, intrinsics);
figure 
imshowpair(I1, I2, 'montage');
title('Undistorted Images');
%%
% Detect feature points
imagePoints1 = detectMinEigenFeatures(im2gray(I1), MinQuality = 0.1);

% Visualize detected points
figure
imshow(I1, InitialMagnification = 50);
title('150 Strongest Corners from the First Image');
hold on
plot(selectStrongest(imagePoints1, 150));
%%
% Create the point tracker
tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

% Visualize correspondences
figure
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
title('Tracked Features');

%%
% Estimate the fundamental matrix
[E, epipolarInliers] = estimateEssentialMatrix(...
    matchedPoints1, matchedPoints2, intrinsics, Confidence = 99.99);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% Display inlier matches
figure
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');
%%
relPose = relativeCameraPose(E, intrinsics, inlierPoints1, inlierPoints2);
%%
% Detect dense feature points. Use an ROI to exclude points close to the
% image edges.
border = 30;
roi = [border, border, size(I1, 2)- 2*border, size(I1, 1)- 2*border];
imagePoints1 = detectMinEigenFeatures(im2gray(I1), ROI = roi, ...
    MinQuality = 0.001);

% Create the point tracker
tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

% Compute the camera matrices for each position of the camera
% The first camera is at the origin looking along the Z-axis. Thus, its
% transformation is identity.
camMatrix1 = cameraProjection(intrinsics, rigidtform3d);
camMatrix2 = cameraProjection(intrinsics, pose2extr(relPose));

% Compute the 3-D points
points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);

% Get the color of each reconstructed point
numPixels = size(I1, 1) * size(I1, 2);
allColors = reshape(I1, [numPixels, 3]);
colorIdx = sub2ind([size(I1, 1), size(I1, 2)], round(matchedPoints1(:,2)), ...
    round(matchedPoints1(:, 1)));
color = allColors(colorIdx, :);

% Create the point cloud
ptCloud = pointCloud(points3D, 'Color', color);