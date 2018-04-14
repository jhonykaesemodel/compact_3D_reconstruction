function show_deformed_models(obj, i, j, is_color_mesh)

if nargin < 4
    is_color_mesh = true;
end

if is_color_mesh
    color_gca = [7 54 66]/255;
    color_model = [38 139 210]/255;
    edge_color = 'none';
else
    color_gca = [7 54 66]/255;
    color_model = 'none';
    edge_color = [38 139 210]/255;
end

% load deformed model
data_paths;
mat_file = fullfile(tmp_shapenet_dir, obj.class_uid, ...
sprintf('node%02dto%02d.mat', i, j));
load(mat_file);

figure;
subplot(2, 3, 1);
show_model(obj.nodes{i}.FFD, 'FaceColor', color_model, 'ColorGCA', color_gca, 'MarkerSize', 20, 'isLattice', true, 'EdgeColor', edge_color);
title(sprintf('Source: Node %d', i));

subplot(2, 3, 2);
model.FFD.vtx = model.FFD.B * model.FFD.Phat;
show_model(model.FFD, 'FaceColor', color_model, 'ColorGCA', color_gca, 'MarkerSize', 20, 'isLattice', true, 'EdgeColor', edge_color);
title(sprintf('Source deformed by FFD to fit the Target'));

if is_color_mesh
    color_model = 'b';
    edge_color = 'none';
else
    color_model = 'none';
    edge_color = 'b';
end

subplot(2, 3, 3);
show_model(obj.nodes{j}.FFD, 'MarkerSize', 20, 'isLattice', false, 'FaceColor', color_model, 'EdgeColor', edge_color);
title(sprintf('Target: Node %d', j));

subplot(2, 3, 4);
show_model(model, 'MarkerSize', 20, 'isLattice', false, 'FaceColor', color_model, 'EdgeColor', edge_color);
title(sprintf('Deformed model by Nonrigid ICP \n Deformed %d -> %d - Score: %f', ...
    i, j, model.score));

subplot(2, 3, 5);
show_model(model, 'MarkerSize', 20, 'isLattice', false, 'FaceColor', color_model, 'EdgeColor', edge_color);
title('Deformed model (view 2)');
view(2);

subplot(2, 3, 6);
show_model(model, 'MarkerSize', 20, 'isLattice', false, 'FaceColor', color_model, 'EdgeColor', edge_color);
title('Deformed model (view 3)');
view(-92,1);
