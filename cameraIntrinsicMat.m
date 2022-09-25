function K = cameraIntrinsicMat()

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

end