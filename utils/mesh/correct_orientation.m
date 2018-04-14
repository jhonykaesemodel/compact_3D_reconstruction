function R = correct_orientation(info)
% Correct orientation of model based on up and front direction in model info
up(1) = -info.up(2);
up(2) =  info.up(3);
up(3) =  info.up(1);
front(1) = -info.front(2);
front(2) =  info.front(3);
front(3) =  info.front(1);
H = [up', front']*[0, 0, 1; -1, 0, 0];
[U, ~, V] = svd(H);
R = V*U';
