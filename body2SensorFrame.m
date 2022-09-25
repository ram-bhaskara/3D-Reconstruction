function point = body2SensorFrame(Rt,bodyFrameCoord)

% transform from body frame to the sensor frame using the homogenous
% transformation [R t] (3 x 4) 

% [R t] -> transformation (R, t) from body frame to the sensor frame

% bodyFrameCoord - 3 x 1 3d coordinate in body frame

point = Rt * [bodyFrameCoord; 1];

end