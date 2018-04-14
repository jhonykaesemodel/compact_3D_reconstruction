root = 'C:\datasets';
current_folder = pwd;

% ShapeNet
ShapeNet_dir = fullfile(root, 'ShapeNetCore.v1');

% Pascal 3D+
PASCAL3D_dir = fullfile(root, 'PASCAL3D+_release1.1');
VOC_dir = fullfile(root, 'PASCAL3D+_release1.1', 'PASCAL', 'VOCdevkit', 'VOC2012');
Anchor_dir_Pascal = fullfile(root, 'PASCAL3D+_release1.1', 'Anchor');

% Results
Result_dir = fullfile(current_folder, 'data', 'PascalResult');
Anchor_dir = fullfile(current_folder, 'data', 'ShapeNetAnchors');
Graph_dir = fullfile(current_folder, 'data', 'ShapeNetGraph');
tmp_shapenet_dir = fullfile(current_folder, 'data', 'ShapeNetMat.v1');
SyntheticData_dir = fullfile(current_folder, 'data', 'FFD_UI_synthetic');
