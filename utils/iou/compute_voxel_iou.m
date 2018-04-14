function voxelIoU_score = compute_voxel_iou(fgraph, i, j, isPlot)

add_paths;
data_paths;

if nargin < 4
    isPlot = false;
end

target = fgraph.nodes{j}; % load target
target_uid = target.model_info.uid;

%% load target model
target_vxl_filename = fullfile(tmp_shapenet_dir, fgraph.class_uid, [target_uid, '_vxl.mat']);
load(target_vxl_filename);
target_vxl = voxel;

%% load deformed model
deformed_model_vxl = sprintf('node%02dto%02d_vxl.mat', i, j);
deformed_filename = fullfile(tmp_shapenet_dir, fgraph.class_uid, deformed_model_vxl);
load(deformed_filename);
model_vxl = voxel;

%% compute IoU
voxelIoU_score = voxel_iou_score(model_vxl.data, target_vxl.data);


%% visualize
if isPlot
    colorGCA = [29 31 33]/255;
    colorModelSource = [220 50 47]/255;
    colorModelTarget = [38 139 210]/255;
    
    figure;
    set(gcf,'Color',colorGCA);
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf, 'ColorMap', [colorModelSource; colorModelTarget])
    
    Alpha = zeros(size(target_vxl.data));
    Alpha(target_vxl.data == 1) = 0.5;
    h1 = vol3d('cdata', target_vxl.data, 'Alpha', Alpha);
    axis equal off;
    view(3);
    hold on
    Alpha = zeros(size(model_vxl.data));
    Alpha(model_vxl.data == 1) = 0.5;
    h2 = vol3d('cdata', ~model_vxl.data, 'Alpha', Alpha);
    axis equal off;
    view(3);
    lgd = legend([h1.handles(1), h2.handles(1)], {'Source','Target'}, 'Location', 'best');
    lgd.TextColor = [0 43 54]/255;
    lgd.Color = [253 246 227]/255;
    
    % subplots
    figure;
    set(gcf, 'Position', get(0, 'Screensize'));
    set(gcf, 'ColorMap', [colorModelSource; colorModelTarget])
    set(gcf, 'Color', colorGCA);
   
    subplot(1,2,1)
    Alpha = zeros(size(target_vxl.data));
    Alpha(target_vxl.data == 1) = 0.5;
    vol3d('cdata', target_vxl.data, 'Alpha', Alpha);
    axis equal off;
    view(3);
    title('Target', 'Color', [253 246 227]/255)
    
    subplot(1,2,2)
    Alpha = zeros(size(model_vxl.data));
    Alpha(model_vxl.data == 1) = 0.5;
    vol3d('cdata', ~model_vxl.data, 'Alpha', Alpha);
    axis equal off;
    view(3);
    title('Deformed model', 'Color', [253 246 227]/255)  
end
