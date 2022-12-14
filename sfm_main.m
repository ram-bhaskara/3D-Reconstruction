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

nFeatures = 100;
[f1, f2] = matchFeatures_truthInit(Img1, Img2, nFeatures);
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
% disp([u,v])
% disp([xm,ym,zm])

%% Ground truth 3D coordinates
coords_3d = [xm ym zm]'; 
point3d_SF_truth = zeros(3, length(coords_3d)); 

for ii = 1:length(coords_3d)
    point3d_SF_truth(:,ii) = body2SensorFrame(Rt_frame1,coords_3d(:,ii));
end
%% Depth estimation in sensor frame
K1 = cameraIntrinsicMat();
K2 = cameraIntrinsicMat();
point3d_SF_estimate = zeros(3, length(coords_3d)); % least squares
point3d_SF_estimate2 = point3d_SF_estimate; % perspective projtxn soln

%%% LEAST SQUARES APPROACH

% for ii = 1:length(coords_3d)
%     pixel_coords = [[500, 500] - f1(ii,:); [500, 500] - f2(ii,:)]; % [u1, v1; u2, v2]
% % pixel_coords = [f1(ii,:); f2(ii,:)];   
% point3d_SF_estimate(:,ii) = compute_point(pixel_coords, K1, K2, Rt_f1f2);  % estimate in sensor frame
% end

%%% SUBSTITUTION APPROACH 

for ii = 1:length(coords_3d)
    pixel_coords = [[500, 500] - f1(ii,:); [500, 500] - f2(ii,:)]; % [u1, v1; u2, v2] 
    point3d_SF_estimate2(:,ii) = compute_point2(pixel_coords, K1, K2, Rt_f1f2);  % estimate in sensor frame
end

%% COMPARISON WITH GROUND TRUTH: Verify UV points 

uv_truth = zeros(2, length(coords_3d)); 
uv_est = uv_truth; 
for ii = 1:length(coords_3d)
    x_new_truth = K*point3d_SF_truth(:,ii);
    uvw_truth = x_new_truth./x_new_truth(3);
    uvw_truth = [500; 500; 1] - uvw_truth;
    uv_truth(:,ii) = uvw_truth(1:2);

    x_new_est = K*point3d_SF_estimate2(:,ii);
    uvw_est = x_new_est./x_new_est(3);
    uvw_est = [500; 500; 1] - uvw_est;
    uv_est(:,ii) = uvw_est(1:2);
end

pixel_dist = zeros(length(coords_3d),1);
for ii = 1:length(coords_3d)
    pixel_dist(ii) = pdist([transpose(uv_truth(:,ii)); transpose(uv_est(:,ii))],'euclidean');
end

[pixel_errors, ID_px_err] = sort(pixel_dist); 
sorted_uv_truth = uv_truth(:,ID_px_err);
sorted_uv_est = uv_est(:,ID_px_err);

figure 
% Worst 20 pixel map
imshow(Img1); 
hold on
plot(sorted_uv_truth(1,end-20:end),sorted_uv_truth(2,end-20:end),'og','MarkerSize',10,'MarkerFaceColor','none');
plot(sorted_uv_est(1,end-20:end),sorted_uv_est(2,end-20:end),'xr','MarkerSize',8,'MarkerFaceColor','none');
hold off
% title('Truth vs estimated pixel coordinates')
legend('Truth','Estimate','Fontsize',15)

% figure 
% % Best 20 pixel map
% imshow(Img1); 
% hold on
% plot(sorted_uv_truth(1,1:20),sorted_uv_truth(2,1:20),'^b','MarkerSize',10,'MarkerFaceColor','none');
% plot(sorted_uv_est(1,1:20),sorted_uv_est(2,1:20),'xr','MarkerSize',8,'MarkerFaceColor','none');
% hold off
% % title('Truth vs estimated pixel coordinates')
% legend('Truth','Estimate','Fontsize',15)
%% VALIDATION METRICS: Relative error percentages
rel_errors = abs(point3d_SF_estimate2 - point3d_SF_truth)./abs(point3d_SF_truth); 
rel_percentages = rel_errors*100; 

abs_errors = abs(point3d_SF_estimate2 - point3d_SF_truth);

figure
subplot(2,1,1)
h = boxplot(abs_errors','Labels',{'x','y','z'}, ...
    'PlotStyle','compact','Symbol','+r','Jitter',0,'Orientation','horizontal');
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 15);
xlabel('Absolute Errors (m)','FontSize',15)

subplot(2,1,2)
h = boxplot(rel_percentages','Notch','off','Labels',{'x','y','z'}, ...
    'PlotStyle','compact','Symbol','+r','Jitter',0,'Orientation','horizontal');
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 15);
xlabel('Relative Error (%)','fontsize',15)


