%% Set paths
add_paths;

%% load 3D model
model = load('bunny.mat');
model = model.bunny;

%% rotate the bunny by 90 degrees around the x axis
theta = 90;
Rx = [  1  0           0;
    0  cosd(theta)  -sind(theta);
    0  sind(theta)  cosd(theta)];
model.vertices = (Rx*model.vertices')';

%% compute the FFD of the CAD model
% set the number of planes for the FFD (l+1, m+1, n+1)
l = 3; m = 3; n = 3;
model_FFD = compute_FFD(model, l, m, n);

% randomly generate deformations (deltaP)
sigma_min = 0.001;
sigma_max = 0.009;
vec_deltaPt = zeros(size(vec(model_FFD.P)));
sigma = sigma_min + rand(1)*(sigma_max - sigma_min);
% matrix to impose symmetry
phi = symmetric_matrix(model_FFD.P, l, m, n);
vec_deltaPt = vec_deltaPt + phi*sigma*randn(size(vec_deltaPt)); % noisy signal

% deformed the FFD lattice and return the CAD model deformed (model_def)
[model_def, model_FFD_def] = deform_FFD_lattice(model_FFD, vec_deltaPt);

%% visualize
color_gca = [7 54 66]/255;
color_model = [38 139 210]/255;

figure,
subplot(1,2,1)
show_model(model_FFD, 'FaceColor', color_model, 'ColorGCA', color_gca, ...
        'MarkerSize', 20, 'isAnchor', false, 'isLattice', true);
title('Original FFD')
    
subplot(1,2,2)
show_model(model_FFD_def, 'FaceColor', color_model, 'ColorGCA', color_gca, ...
        'MarkerSize', 20, 'isAnchor', false, 'isLattice', true);
title('Deformed lattice')
