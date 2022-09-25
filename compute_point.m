function est = compute_point(pixel_coords, K1, K2, Rt)

ul = pixel_coords(1,1); vl = pixel_coords(1,2);
ur = pixel_coords(2,1); vr = pixel_coords(2,2);

%%%%%%%%%%%%%%%%%%% Version 1 %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Homogenous coordinates %%%%%%%%%%%%%%%
col4 = [0 0 0]';
K1 = [K1, col4]; K2 = K1; 
% 
M = K2 * Rt; 
% 
p11 = K1(1,1); p12 = K1(1,2); p13 = K1(1,3); p14 = K1(1,4);
p21 = K1(2,1); p22 = K1(2,2); p23 = K1(2,3); p24 = K1(2,4);
p31 = K1(3,1); p32 = K1(3,2); p33 = K1(3,3); p34 = K1(3,4);

m11 = M(1,1); m12 = M(1,2); m13 = M(1,3); m14 = M(1,4);
m21 = M(2,1); m22 = M(2,2); m23 = M(2,3); m24 = M(2,4);
m31 = M(3,1); m32 = M(3,2); m33 = M(3,3); m34 = M(3,4);
% 
% % A: 4x3 matrix
A = [ul*p31-p11     ul*p32-p12   ul*p33-p13;
    vl*p31-p21      vl*p32-p22   vl*p33-p23;
    ur*m31-m11      ur*m32-m12   ur*m33-m13;
    vr*m31-m21      vr*m32-m22   vr*m33-m23
    ];

b = [p14-ul*p34;
    p24-vl*p34;
    m14-ur*m34;
    m24-vr*m34];
% 
% b = [p14-1*p34;
%     p24-1*p34;
%     m14-1*m34;
%     m24-1*m34];

est = inv(A'*A) * A' * b; 
% [U,S,V] = svd(A)

end