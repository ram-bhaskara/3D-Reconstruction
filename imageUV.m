function [U1,V1] = imageUV(u,v)
   FOV = 30;
   nx = 500; ny = 500;
 
   h = 2*tand(FOV/2);
   w = ny/nx*h;
   sx = w/nx;
   sy = h/ny;
% 35 mm film equivalent units
% https://en.wikipedia.org/wiki/Angle_of_view

% h = 24; % mm 
% w = 36; % mm
% sx = w/nx;
% sy = h/ny;
U1 = (u - nx/2)*sx;
V1 = (v - ny/2)*sy;

end