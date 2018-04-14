function model = load_FFD_model(class_uid, model_uid, varargin)
% Function to load model from dataset
%
%   To load model from ShapeNet with automatically alignment, run
%       model = load_FFD_model(class_uid, model_uid, 'AlignedAuto', true);
%
%   To load model from ShapeNet aligned to reference model, run
%       model = load_FFD_model(class_uid, model_uid, 'AlignRefModel', modelRef);
%
%   To load one model from PASCAL3D+, run
%       model = load_FFD_model(cls, model_idx, 'dataset', 'pascal');
%
%   To load all models from PASCAL3D+, run
%       models = load_FFD_model(cls, [], 'dataset', 'pascal');

ip = inputParser;
addOptional(ip, 'AlignedAuto', true, @islogical);
addOptional(ip, 'AlignRefModel', []);
addOptional(ip, 'load_info', true, @islogical);
addOptional(ip, 'dataset', 'shapenet');
parse(ip, varargin{:});
option = ip.Results;

switch lower(option.dataset)

case 'shapenet'
    % to fast debug, load MAT file, need to be removed before releasing
    data_paths;
    mat_file = fullfile(tmp_shapenet_dir, class_uid, [model_uid, '.mat']);
    if exist(mat_file, 'file')
        load(mat_file);
        return;
    end
    % load object model
    data_paths
    obj_dir = fullfile(ShapeNet_dir, class_uid, model_uid, 'model.obj');
    object = load_obj(obj_dir);

    % create output
    model.class_uid = class_uid;
    model.dataset = option.dataset;

    % add info for model
    info = extract_model_info(class_uid, 'model_uid', model_uid);
    if option.load_info
        model.model_info = info;
    end

    % add anchors if exist
    anchor_dir = fullfile(Anchor_dir, class_uid, model_uid, 'anchor.mat');
    anchor_names_dir = fullfile(Anchor_dir, class_uid, 'anchor_names.mat');
    if exist(anchor_names_dir, 'file')
        mat_content = load(anchor_names_dir);
        model.anchor_names = mat_content.anchor_names;
        if exist(anchor_dir, 'file')
            mat_content = load(anchor_dir);
            model.anchor = mat_content.anchors;
        else
            model.anchor = [];
        end
    else
        model.anchor_names = {};
        model.anchor = [];
    end

    % adjust vertices for visualization
    model.vtx = object.v';
    if option.AlignedAuto
        R = correct_orientation(info);
        model.vtx = model.vtx*R';
    else
        R = [0,0,1; -1,0,0; 0,1,0];
        model.vtx = model.vtx*R';
    end
    if ~isempty(option.AlignRefModel)
        R = align_models(model, option.AlignRefModel);
        model.vtx = model.vtx*R';
    end
    model.mesh = object.f3';

    % remove meshes that is degenerated
    % Note that this is a temporary solution
    invalid_mesh = [];
    for i = 1:size(model.mesh, 1)
        if rank(model.vtx(model.mesh(i, :), :)) ~= 3
            invalid_mesh = [invalid_mesh; i];
        end
    end
    model.mesh(invalid_mesh, :) = [];
        
    % compute FFD of the CAD model
    % set the number of planes for the FFD (l+1, m+1, n+1)
    l = 3; m = 3; n = 3;
    FFD = compute_FFD(model, l, m, n);
    model.FFD = FFD;
    
    if option.load_info
        model = compute_mesh_info(model);
        model.FFD = compute_mesh_info(model.FFD);
    end
     

    %% save the data in mat format to save time for debugging
    % need to remove before releasing
    data_paths
    if ~exist(tmp_shapenet_dir, 'dir')
        mkdir(tmp_shapenet_dir);
    end
    tmp_class_dir = fullfile(tmp_shapenet_dir, class_uid);
    if ~exist(tmp_class_dir, 'dir')
        mkdir(tmp_class_dir);
    end
    save(fullfile(tmp_class_dir, [model_uid, '.mat']), 'model');

case 'pascal'
    % load object model
    data_path;
    obj_dir = fullfile(PASCAL3D_dir, 'CAD', [class_uid, '.mat']);
    mat_content = load(obj_dir);
    if isempty(model_uid)
        model = cell(numel(mat_content.(class_uid)), 1);
        for i = 1:numel(mat_content.(class_uid))
            object = mat_content.(class_uid)(i);
            % create output
            model{i}.class_uid = class_uid;
            model{i}.model_uid = i;
            model{i}.vtx = object.vertices;
            model{i}.mesh = object.faces;
            model{i}.dataset = option.dataset;

            % add anchors if exist
            anchor_names = class_anchor_tags(class_uid);
            model{i}.anchor_names = anchor_names;
            model{i}.anchor = zeros(1, numel(model{i}.anchor_names));
            for j = 1:numel(model{i}.anchor_names)
                dist = pdist2(object.(model{i}.anchor_names{j}), model{i}.vtx);
                [~, anchor] = min(dist);
                model{i}.anchor(j) = anchor;
            end

            % remove meshes that is degenerated
            % Note that this is a temporary solution
            invalid_mesh = [];
            for j = 1:size(model{i}.mesh, 1)
                if rank(model{i}.vtx(model{i}.mesh(j, :), :)) ~= 3
                    invalid_mesh = [invalid_mesh; j];
                end
            end
            model{i}.mesh(invalid_mesh, :) = [];
            if option.load_info
                model{i} = compute_mesh_info(model{i});
            end
        end
    else
        object = mat_content.(class_uid)(model_uid);

        % create output
        model.class_uid = class_uid;
        model.model_uid = model_uid;
        model.vtx = object.vertices;
        model.mesh = object.faces;
        model.dataset = option.dataset;

        % add anchors if exist
        anchor_names = class_anchor_tags(class_uid);
        model.anchor_names = anchor_names;
        model.anchor = zeros(1, numel(model.anchor_names));
        for i = 1:numel(model.anchor_names)
            if isempty(object.(model.anchor_names{i}))
                model.anchor(i) = 0;
            else
                dist = pdist2(object.(model.anchor_names{i}), model.vtx);
                [~, anchor] = min(dist);
                model.anchor(i) = anchor;
            end
        end

        % remove meshes that is degenerated
        % Note that this is a temporary solution
        invalid_mesh = [];
        for i = 1:size(model.mesh, 1)
            if rank(model.vtx(model.mesh(i, :), :)) ~= 3
                invalid_mesh = [invalid_mesh; i];
            end
        end
        model.mesh(invalid_mesh, :) = [];
        if option.load_info
            model = compute_mesh_info(model);
        end
    end

otherwise
    error('Dataset %s not found', option.dataset);
end
