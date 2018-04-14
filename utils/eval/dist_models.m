function score = dist_models(model, target, theta)
% Evaluate the deformed surface MODEL againt target surface TARGET given
% parameter THETA
%
%   score = dist_models(model, target, theta);
%

% compute distance from model to target
kdtree = KDTreeSearcher(target.vtx);
[U,~] = surf_projection(model, target, kdtree);
dist_model_target = sum(sum((model.vtx - U).^2, 2) > theta)...
    / size(model.vtx, 1);

% compute distance from target to model
kdtree = KDTreeSearcher(model.vtx);
[U,~] = surf_projection(target, model, kdtree);
dist_target_model = sum(sum((target.vtx - U).^2, 2) > theta) ...
    / size(target.vtx, 1);

score = dist_model_target + dist_target_model;
