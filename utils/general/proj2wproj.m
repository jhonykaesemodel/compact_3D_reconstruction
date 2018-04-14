function R = proj2wproj(viewpoint)
% Convert projective projection to weak projective projection

a = viewpoint.azimuth*pi/180;
e = viewpoint.elevation*pi/180;
theta = viewpoint.theta*pi/180;

% Rotate coordinate system by theta is equal to rotating the model by -theta.
% a = -a;
% e = -(pi/2-e);
% t = -theta;
a = -a;
e = -(pi/2-e);
t = -theta;

% rotation matrix
Rz = [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];   %rotate by a
Rx = [1 0 0; 0 cos(e) -sin(e); 0 sin(e) cos(e)];   %rotate by e
%Ry = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];   %rotate by theta
Ry = [cos(t) 0 sin(t); 0 1 0; -sin(t) 0 cos(t)];   %rotate by t
R = Ry*Rx*Rz;

Rz = [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];   %rotate by a
Rx = [1 0 0; 0 cos(e) -sin(e); 0 sin(e) cos(e)];   %rotate by e
R = Rx*Rz;
