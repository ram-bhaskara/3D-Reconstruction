function point = compute_point2(pixel_coords, K_l, K_r, Rt_f1f2)

% left and right camera intrinsics
fx_l = K_l(1,1); fy_l = K_l(2,2); Ox_l = K_l(1,3); Oy_l = K_l(2,3);
fx_r = K_r(1,1); fy_r = K_r(2,2); Ox_r = K_r(1,3); Oy_r = K_r(2,3);

% pixels
u_l = pixel_coords(1,1); v_l = pixel_coords(1,2);
u_r = pixel_coords(2,1); v_r = pixel_coords(2,2);

% modified variables
u_lm = u_l - Ox_l; v_lm = v_l - Oy_l;
u_rm = u_r - Ox_r; v_rm = v_r - Oy_r;


R = Rt_f1f2(1:3, 1:3);
t = Rt_f1f2(1:3, 4);
% from derived formulae

zl = (t(3)*u_rm - fx_r*t(1)) / ( (R(1,1)*u_lm*fx_r - R(3,1)*u_rm*u_lm)/fx_l + ...
    (R(1,2)*v_lm*fx_r - R(3,2)*u_rm*v_lm)/fy_l + (fx_r*R(1,3) - u_rm*R(3,3)) );


% zl_y = (t(3)*v_rm - t(2)*fy_r) / ( (R(2,1)*u_lm*fy_r-R(3,1)*u_lm*v_rm)/fx_l + ...
%     (R(2,2)*v_lm*fy_l-R(3,2)*v_lm*v_rm)/fy_l + (R(2,3)*fy_r-R(3,3)*v_rm) );

xl = zl * u_lm/fx_l; 
yl = zl * v_lm/fy_l; 


point = [xl; yl; zl];


end
