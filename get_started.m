%% Set paths
add_paths;
data_paths;

%% Set object class
class = 'aeroplane';
class_uid = class2uid(class);

%% Load the graph
graph_file = fullfile(Graph_dir, sprintf('%s.mat', class_uid));
fgraph = load(graph_file);
fgraph = fgraph.obj;

%% Load images from Pascal3D+
disp('Loading Pascal images... ')
filenames = get_pascal_images(class);
ifilename = 1; % choose image index
filename = filenames{ifilename};
fprintf('Working on %s \n', filename);
% load a single image
I = load_pascal3D(class, filename);
I = I{1};
figure, imshow(I.image)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Selecting a 3D model...
objs = cell(numel(fgraph),1);

start_loop = tic;
for i = 1:fgraph.num_nodes
    obj = ExtrinsicsEstimation(I, fgraph);
    setParameters(obj, 'constC', i, ...
        'rho', 1e-2, ...
        'rate_rho', 1.01, ...
        'max_rho', 1e5, ...
        'max_iters', 1e3, ...
        'obj_tol', 1e-7, ...
        'dobj_tol', 1e-7, ...
        'is_detail', true, ...
        'is_normalize', true, ...
        'gamma', 1.2); % 1e4 to be regular PnP - 0.1 for synthetic
    if ~isempty(obj.FFD{i}.B)
        [projection, c] = run(obj);
        
        objs{i}.obj = obj;
        objs{i}.FFD = obj.FFD{i};
        objs{i}.projection = projection;
    else
        objs{i}.obj = [];
        objs{i}.FFD = [];
        objs{i}.projection = [];
    end
end
end_loop = toc(start_loop)/60;
fprintf('Done in %.2f min! \n', end_loop);

%% Show the selected/deformed(FFD) 3D CAD model that fits the image anchors
colorGCA = [7 54 66]/255;
colorModel = [38 139 210]/255;

figure
for i = 1:fgraph.num_nodes
    if ~isempty(objs{i}.FFD)
        subplot(1,3,1)
        show_model(fgraph.nodes{i}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
            'MarkerSize', 20, 'isAnchor', true, 'isLattice', true);
        hold off
        
        subplot(1,3,2)
        show_model(objs{i}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
            'MarkerSize', 20, 'isAnchor', true, 'isLattice', true);
        hold off
        
        subplot(1,3,3)
        show_landmarks(I, 'model', objs{i}.FFD, ...
            'projection', objs{i}.projection, 'show_connection', true, 'maskFac', 0);
        hold off
        
        drawnow
        disp("Press any key to jump to other models...")
        pause % To navigate through all models.
    end
end

%% Select the best 3D CAD model
costs = zeros(fgraph.num_nodes,1);
repr_err = zeros(fgraph.num_nodes,1);
for i = 1:fgraph.num_nodes
    if ~isempty(objs{i}.FFD)
        costs(i) = objs{i}.obj.cost;
        repr_err(i) = objs{i}.obj.proj_err;
    else
        costs(i) = inf;
        repr_err(i) = inf;
    end
end
[costs_sorted, costs_idx] = sort(costs, 'ascend');
[repr_err_sorted, repr_err_idx] = sort(repr_err, 'ascend');
c_rep = repr_err_idx(1);
[c, idxIoU, JD] = compute_iou(objs, I);

%% Show the selected 3D CAD model
figure
subplot(1,3,1)
show_model(fgraph.nodes{c}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
    'MarkerSize', 20, 'isAnchor', true, 'isLattice', true);

subplot(1,3,2)
show_model(objs{c}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
    'MarkerSize', 20, 'isAnchor', true, 'isLattice', true);

subplot(1,3,3)
show_landmarks(I, 'model', objs{c}.FFD, ...
    'projection', objs{c}.projection, 'show_connection', true, 'maskFac', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2: Refining the 3D model...
isFFD = true;
sfit = SilhouetteFitting(I, objs{c}.projection, c, fgraph, objs{c}, isFFD);
sfit.set_param('mu', 0.2, 'L2rho', 1e3, ...
    'obj_tol', 1e-7, 'max_iters', 3e3, ...
    'is_CamUPDA', true, ...
    'is_OmeUPDA', true);
[projection_sf, model_sf] = sfit.run;

%% Show final results
figure
subplot(2,3,1)
show_model(fgraph.nodes{c}, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
    'MarkerSize', 20, 'isAnchor', true, 'isLattice', false);
title('CAD chosen')

subplot(2,3,2)
if isFFD
    show_model(objs{c}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
        'MarkerSize', 20, 'isAnchor', true, 'isLattice', true);
    title('CAD chosen with FFD to fit the image')
else
    show_model(fgraph.nodes{c}, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
        'MarkerSize', 20, 'isAnchor', true, 'isLattice', false);
    title('CAD chosen without FFD to fit the image')
end

subplot(2,3,3)
show_landmarks(I, 'model', objs{c}.FFD, ...
    'projection', objs{c}.projection, 'show_connection', true, 'maskFac', 0);
title('Image with the FFD CAD model overlaid')

subplot(2,3,4)
show_landmarks(I, 'model', model_sf, ...
    'projection', projection_sf, 'show_connection', true, 'maskFac', 0);
title('Refined CAD - silhouette fitting')

subplot(2,3,5)
show_model(model_sf, 'MarkerSize', 20, 'isAnchor', true, 'isLattice', false);
title('Final 3D model')

subplot(2,3,6)
show_model(model_sf, 'MarkerSize', 20, 'isAnchor', true, 'isLattice', false);
view(2)
title('Final 3D model (view 2)')

%% Eval results
theta = 0.1;
[errR, errS] = eval_result(I, fgraph.nodes{c}, projection_sf, theta);
