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

%% Depth estimation in sensor frame

pixel_coords = [[500, 500] - f1(3,:); [500, 500] - f2(3,:)]; % [u1, v1; u2, v2]
K1 = cameraIntrinsicMat();
K2 = cameraIntrinsicMat();
point3d = compute_point(pixel_coords, K1, K2, Rt_f1f2); 

%% Verify UV points
coords_3d = [xm ym zm]'; 
x_new = K*Rt_frame1*[coords_3d(:,3); 1];
uvw = x_new./x_new(3);
uvw = [500; 500; 1] - uvw;

uv = uvw(1:2)