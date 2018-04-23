root = 'C:\datasets';

% ShapeNet
ShapeNet_dir = fullfile(root, 'ShapeNetCore.v1');

% Pascal 3D+
PASCAL3D_dir = fullfile(root, 'PASCAL3D+_release1.1');
VOC_dir = fullfile(root, 'PASCAL3D+_release1.1', 'PASCAL', 'VOCdevkit', 'VOC2012');
Anchor_dir_Pascal = fullfile(root, 'PASCAL3D+_release1.1', 'Anchor');

% Results
Result_dir = fullfile(root, 'PascalResult');
Anchor_dir = fullfile(root, 'ShapeNetAnchors');
Graph_dir = fullfile(root, 'ShapeNetGraph');
tmp_shapenet_dir = fullfile(root, 'ShapeNetMat.v1');
SyntheticData_dir = fullfile(root, 'FFD_UI_synthetic');
