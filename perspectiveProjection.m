% Perspective projection transformation

% Resources:
% https://www.edmundoptics.in/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/
% https://answers.opencv.org/question/17076/conversion-focal-distance-from-mm-to-pixels/
% https://ksimek.github.io/2013/08/13/intrinsic/

% film dimensions: 35 mm
vfov = 30; % deg
img_width = 500; % px
img_height = 500;

hfov = vfov * img_width/img_height; 

fy = img_height * 0.5 / (tan (vfov * 0.5 * pi/180) );

fx = img_width * 0.5 / (tan (hfov * 0.5 * pi/180) );

% optical center
Ox = img_width/2.0; 
Oy = img_height/2.0;

% camera intrinsic matrix
K = [fx 0 Ox;
    0 fy Oy;
    0 0 1]; 

%% 2D to 3D transformation
addpath('images','3D_data')
IMG_fileNames = dir(fullfile('images','Rh_Narpa_*.png'));
IMG_fileNames = {IMG_fileNames.name}';

%% extract a feature
% figure
[f1, f2] = matchFeatures_truthInit("Rh_Narpa_800.png", "Rh_Narpa_800.png");

%% 3D file
[xm,ym,zm,u,v,U,V] = readImage('rh_n_00_3D_800.txt', 4);

%% Correspondence
LookFrom = [0 800 0]'; 
LookAt = [0 0 0]';
up = [1 0 0]';
R = cameraDCM(LookFrom, LookAt, up);
t = [0 0 800]'; % t = R' * (LookAt - LookFrom) in the sensor frame
Rt = [R',t; zeros(1,3) 1];

coords_3d = [xm ym zm]'; 

% [u,v] = XYZ2pix(xm(1),ym(1),zm(1),Rt)
% K'*coords_3d(:,1)
%% world-frame coordinates
% PnP - validated - working!
% Rt*[1 1 1 1]'
K = [fx 0 Ox;
    0 fy Oy;
    0 0 1]; 
x_new = [K zeros(3,1)]*Rt*[coords_3d(:,1); 1];
uvw = x_new./x_new(3);
uvw = [500; 500; 1] - uvw;
uv = uvw(1:2);
%%
function R = cameraDCM(LookFrom, LookAt, up)
    
    LookAt = reshape(LookAt, [3,1]);
    LookFrom = reshape(LookFrom, [3,1]);
    up = reshape(up, [3,1]);
    
    zaxis = LookAt - LookFrom; % pointing in the camera plane 
    zaxis = zaxis./norm(zaxis);
    
    xaxis = cross(up, zaxis); 
    xaxis = xaxis./norm(xaxis); 
    
    yaxis = cross(zaxis, xaxis); 
    R = zeros(3,3);
    R = [xaxis, yaxis, zaxis];
   
end