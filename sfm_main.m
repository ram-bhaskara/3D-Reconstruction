%% Depth Estimation using NaRPA - differentiable rendering
% Topic: Stereo vision - structure from motion
% Ram Bhaskara | Jul 14, 2022
% Ref: https://www.youtube.com/watch?v=OYwm4VM6uNg&ab_channel=FirstPrinciplesofComputerVision

%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close

% Add relative paths of directories with images and 3D data
addpath('images\','3D_data\');

% Synthetic Images and point clouds are generated using NaRPA
% https://github.tamu.edu/LASR-New/ScORE-Renderer

% Image files
% IMG_fileNames = dir(fullfile('Rh_Narpa_*.png'));
% IMG_fileNames = {IMG_fileNames.name}';

% Data read operation
myData = readtable("metaData.xlsx"); 
lookFroms = myData.lookfrom; 
lookAts = myData.lookat;
ups = myData.up; 
imgFiles = myData.image_file; 
pcFiles = myData.point_cloud_file; 

%% Extract features between Img1 and Img2
Img1 = imgFiles{1};
Img2 = imgFiles{2}; 

[f1, f2] = matchFeatures_truthInit(Img1, Img2);
%% Body frame to Sensor frame transformation

LookFrom_frame1 = str2num(lookFroms{1})'; 
LookAt_frame1 = str2num(lookAts{1})';
up_frame1 = str2num(ups{1})';
R_frame1 = cameraDCM(LookFrom_frame1, LookAt_frame1, up_frame1);
t_frame1 = R_frame1' * ([0 0 0]' - LookFrom_frame1);
Rt_frame1 = [R_frame1',t_frame1];

LookFrom_frame2 = str2num(lookFroms{2})'; 
LookAt_frame2 = str2num(lookAts{2})';
up_frame2 = str2num(ups{2})';
R_frame2 = cameraDCM(LookFrom_frame2, LookAt_frame2, up_frame2);
t_frame2 = R_frame2' * ([0 0 0]' - LookFrom_frame2);
Rt_frame2 = [R_frame2',t_frame2];

% Transformation from frame1 to frame2

R_f1f2 = R_frame2' \ R_frame1';
t_f1f2 = (t_frame2 - t_frame1); 
Rt_f1f2 = [R_f1f2, t_f1f2; zeros(1,3) 1]; 

%% Projection test (Narpa - Mitsuba calibration)
K = cameraIntrinsicMat(); % Image resolution and camera properties

% Find 3D interest points
[xm,ym,zm,u,v,U,V] = readImage(pcFiles{1}, f1);
disp([u,v])
disp([xm,ym,zm])

%% Ground truth 3D coordinates
coords_3d = [xm ym zm]'; 
point3d_SF_truth = zeros(3, length(coords_3d)); 

for ii = 1:length(coords_3d)
    point3d_SF_truth(:,ii) = body2SensorFrame(Rt_frame1,coords_3d(:,ii));
end
%% Depth estimation in sensor frame
K1 = cameraIntrinsicMat();
K2 = cameraIntrinsicMat();
point3d_SF_estimate = zeros(3, length(coords_3d)); 

for ii = 1:length(coords_3d)
    pixel_coords = [[500, 500] - f1(ii,:); [500, 500] - f2(ii,:)]; % [u1, v1; u2, v2]
    point3d_SF_estimate(:,ii) = compute_point(pixel_coords, K1, K2, Rt_f1f2);  % estimate in sensor frame
end


%% Verify UV points 
uv_truth = zeros(2, length(coords_3d)); 
uv_est = uv_truth; 
for ii = 1:length(coords_3d)
    x_new_truth = K*point3d_SF_truth(:,ii);
    uvw_truth = x_new_truth./x_new_truth(3);
    uvw_truth = [500; 500; 1] - uvw_truth;
    uv_truth(:,ii) = uvw_truth(1:2);

    x_new_est = K*point3d_SF_estimate(:,ii);
    uvw_est = x_new_est./x_new_est(3);
    uvw_est = [500; 500; 1] - uvw_est;
    uv_est(:,ii) = uvw_est(1:2);
end

figure 
imshow(Img1); 
hold on
plot(uv_truth(1,:),uv_truth(2,:),'or','MarkerSize',7,'MarkerFaceColor','auto');
plot(uv_est(1,:),uv_est(2,:),'^g','MarkerSize',5,'MarkerFaceColor','auto');
hold off
title('Truth vs estimated pixel coordinates')
legend('Truth','Estimate')