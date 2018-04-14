function [errR, errS] = eval_result(I, model, projection, theta)
if nargin < 4
    theta = 0.1;
end

if ~isfield(I.cad, 'vtx')
    [I.cad.vtx] = I.cad.vertices;
    I.cad = rmfield(I.cad,'vertices');
    [I.cad.mesh] = I.cad.faces;
    I.cad = rmfield(I.cad,'faces');
end

% compare rotation
alignR = align_models(model, I.cad);
alignR = round(alignR); % only allow to rotate k*pi/2
R_gt = I.rotation*alignR;
errR = norm(projection.rotation - R_gt(1:2, :));

% compare cad model
% normalize both models
mask = (I.cad.anchor~=0)&(model.anchor~=0);
mean_est = mean(model.vtx(model.anchor(mask), :), 1);
mean_gtr = mean(I.cad.vtx(I.cad.anchor(mask), :), 1);
model.vtx = bsxfun(@minus, model.vtx, mean_est);
I.cad.vtx = bsxfun(@minus, I.cad.vtx, mean_gtr);

std_est = mean(std(model.vtx(model.anchor(mask), :), 1, 1));
std_gtr = mean(std(I.cad.vtx(I.cad.anchor(mask), :), 1, 1));
model.vtx = model.vtx/std_est;
I.cad.vtx = I.cad.vtx/std_gtr;
R = align_models(model, I.cad);
model.vtx = model.vtx*R';

model = compute_mesh_info(model);
I.cad = compute_mesh_info(I.cad);

errS = dist_models(model, I.cad, theta);
