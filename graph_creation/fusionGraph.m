classdef fusionGraph < handle

    properties(GetAccess = 'public', SetAccess = 'private')
        class_uid;          % the uid of class
        num_nodes;          % the number of nodes
        num_edges;          % the number of edges
        nodes;              % the cell array of model_uids
        connectivity;       % the matrix containing connection confidence
        voxel_iou;          % voxel IoU scores
        edges;              % the matrix containing connection confidence
        throd_metrics;      % the threshold for metrics
        thd_dist;           % the distance threshold for edges
        thd_iou;            % the distance threshold for voxel IoU
    end

    methods
        function obj = fusionGraph(class_uid, models)
            % Construct a fusion graph for a given class
            %
            %   graph = fusionGraph(class_uid);
            %   graph = fusionGraph(class_uid, models);
            %
            %   Note that if input models is omitted, the graph will load all
            %   possible models.
          
            if nargin < 2
                data_paths;
                files = dir(fullfile(Anchor_dir, class_uid));
                models = {};
                for i = 1:numel(files)
                    if ~strcmp(files(i).name(1), '.')
                        if files(i).isdir
                            models = [models; files(i).name];
                        end
                    end
                end
            end
            
            obj.class_uid = class_uid;
            switch class_uid
                case class2uid('diningtable')
                    refModel = 6;
                otherwise
                    refModel = 1;
            end
            fprintf('Loading model %s\n', models{refModel});
            
            % TODO: has to be false for plane, bicycle, motorbike due to
            % alignment issues
            if isequal(obj.class_uid, '02691156') || isequal(obj.class_uid, '02834778') || isequal(obj.class_uid, '03790512')
                isAlign = false;
            else
                isAlign = true;
            end
            obj.nodes{refModel} = load_FFD_model(obj.class_uid, ...
                models{refModel}, 'AlignedAuto', isAlign); 
            
            %figure,show_model(obj.nodes{i})
                             
            for i = 1:numel(models)
                if i == refModel
                    continue;
                end
                fprintf('Loading model %s\n', models{i});
                obj.nodes{i} = load_FFD_model(obj.class_uid, models{i}, ...
                    'AlignRefModel', obj.nodes{refModel});
            end
            obj.num_nodes = numel(obj.nodes);
            obj.connectivity = nan(obj.num_nodes);
            obj.voxel_iou = nan(obj.num_nodes);
            obj.edges = false(obj.num_nodes);
            obj.num_edges = 0;
            obj.throd_metrics = 3e-3;                
        end

        function connect_nodes(obj, theta)
            % Construct connections between each pair of nodes
            %
            %   obj.connect_nodes(theta);
            %   obj.connect_nodes();
            
            data_paths;
            
            if nargin == 2
                obj.throd_metrics = theta;
            end
            
            for i = 1:obj.num_nodes
                for j = 1:obj.num_nodes
                    if i == j
                        obj.connectivity(i, j) = inf;
                        obj.voxel_iou(i, j) = NaN;
                        continue;
                    end
                    if isnan(obj.connectivity(i, j))
                        mat_file = fullfile(tmp_shapenet_dir, obj.class_uid, ...
                            sprintf('node%02dto%02d.mat', i, j));
                        if exist(mat_file, 'file')           
                            load(mat_file)
                            continue;
                        else
                            obj.connect_nodes_pair(i, j);
                        end
                    else
                        fprintf('Connection from Node %d to %d exists\n', i, j);
                    end
                end
            end
        end

        function connect_nodes_pair(obj, i, j)
            % Connect i-th node to j-th node, only called internal
            % to speed up algorithm
            fprintf('Connecting Node %d to Node %d\n', i, j);
            source = obj.nodes{i};
            target = obj.nodes{j};
                    
            mask = ((source.anchor~=0)&(target.anchor~=0));
            source.anchor = source.anchor(mask);
            target.anchor = target.anchor(mask);
                       
            data_paths;
            mat_file = fullfile(tmp_shapenet_dir, obj.class_uid, ...
                sprintf('node%02dto%02d.mat', i, j));
            if exist(mat_file, 'file')
                load(mat_file);                     
            else
                
                % normalize FFD source
                vtx_diff = bsxfun(@minus, source.FFD.vtx', source.vtx');
                mean_diff = mean(vtx_diff,2);
                vtx_norm = bsxfun(@plus, target.vtx', mean_diff);
                target.vtx = vtx_norm';
                
                % align the source landmarks to the target by FFD
                [source, dP, Phat] = alignment_FFD_3D(obj, i, j, 'isCVX', true); % CVX is faster
                
                % compute new normals
                source = compute_mesh_info(source);
                target = compute_mesh_info(target);
                
%                 figure,
%                 show_model(source, 'FaceColor', 'r')
%                 hold on
%                 show_model(target)
                                
                %% 2. Apply non-rigid ICP
%                 model = nricp(source, target, 'epsilon', 1e-3, ... 
%                                                           'is_detail', true, ...
%                                                           'alpha', 20, ...
%                                                           'beta', 1, ...
%                                                           'maxIterN', 20, ...
%                                                           'alphaRelaxRatio', 0.8, ...
%                                                           'gamma', 0.1, ...
%                                                           'plot', false);
                                                      
                model = nricp_no_outer_loop(source, target, 'alpha', 30, ...
                                                                      'epsilon', 3e-4);

                model.FFD.dP = dP;
                model.FFD.Phat = Phat;
                model.FFD.vtx = source.vtx;
                
                
                %% compute the similiarity
                obj.connectivity(i, j) = dist_models( ...
                model, target, obj.throd_metrics);
            
                model.score = obj.connectivity(i, j);

                % centralize model before saving
                vtx_norm = bsxfun(@minus, model.vtx', mean_diff);
                model.vtx = vtx_norm';
                
                save(mat_file, 'model');
            end
        end
        
        function createEdges(obj, voxel_iou, thd_dist, thd_iou)
            % trim connections to remove invalid edges
            obj.thd_dist = thd_dist;
            obj.thd_iou = thd_iou;
            obj.voxel_iou = voxel_iou;
            % reset edges
            obj.edges = false(obj.num_nodes);
                    
            % select first n biggest voxel IoU
            [~, suby_c] = sort(obj.voxel_iou, 2, 'descend');
            ind_c = sub2ind([obj.num_nodes, obj.num_nodes], ...
                repmat((1:obj.num_nodes)', 1, 3), ...
                suby_c(:, 2:4));
            big_iou = false(obj.num_nodes);
            big_iou(ind_c) = true;
              
            % get good connections considering surface dist and voxel IoU 
            good_conn = (obj.connectivity < thd_dist) & (voxel_iou > thd_iou);

            obj.edges = good_conn | big_iou;
            obj.num_edges = numel(find(obj.edges));
           
        end

        function save(obj, path)
            % Save the graph to given path
            if nargin < 2
                data_paths;
                if ~exist(Graph_dir, 'dir')
                    mkdir(Graph_dir);
                end
                path = fullfile(Graph_dir, sprintf('%s.mat', ...
                    obj.class_uid));
            end
            save(path, 'obj');
            fprintf('Graph saved at %s\n', path);
        end

        function drawGraph(obj, varargin)
            ip = inputParser;
            addOptional(ip, 'FontSize', 20, @isnumeric);
            addOptional(ip, 'MarkerSize', 10, @isnumeric);
            addOptional(ip, 'DeltaSize', 20, @isnumeric);
            addOptional(ip, 'LineWidth', 1, @isnumeric);
            addOptional(ip, 'ColorMap', 'winter');
            addOptional(ip, 'Text', true, @islogical);
            addOptional(ip, 'ScaleFactor', 0.9, @isnumeric);
            parse(ip, varargin{:});
            option = ip.Results;
            
            eval(sprintf('cmap = %s(obj.num_nodes);', option.ColorMap));
            angle = 2*pi/obj.num_nodes;
            for i = 1:obj.num_nodes
                plot(cos(i*angle), sin(i*angle), '.', ...
                    'MarkerSize', sum(obj.edges(i, :))*option.DeltaSize + ...
                        option.MarkerSize, 'Color', cmap(i, :));
                hold on;
                if option.Text
                    txt = sprintf('%02d', i);
                    text(1.2*cos(i*angle)-0.06, 1.2*sin(i*angle)-0.01, txt, ...
                        'FontSize', option.FontSize);
                end
            end
            for i = 1:obj.num_nodes
                for j = 1:obj.num_nodes
                    if obj.edges(i, j)
                        quiver(cos(i*angle), sin(i*angle), ...
                            cos(j*angle) - cos(i*angle), ...
                            sin(j*angle) - sin(i*angle), ...
                            'Color', cmap(i, :), 'LineWidth', option.LineWidth, ...
                            'AutoScaleFactor', option.ScaleFactor);
                    end
                end
            end
            axis equal;
            axis off;
            if option.Text
                axis([-1, 1, -1, 1.2]);
            end
        end

        function model = deform_model(obj, i, j)
            % Deform node i to node j, and return the deformed model
            % to speed up debugging, load MAT file, need to be removed before releasing
            data_paths;
            mat_file = fullfile(tmp_shapenet_dir, obj.class_uid, ...
                sprintf('node%02dto%02d.mat', i, j));
          
            fprintf(' Loading the deformed model from %s\n', mat_file);
            load(mat_file);
              
            fprintf(' Deforming model %d to model %d', i, j);
            target = obj.nodes{j};
            source = obj.nodes{i};
            % Utilizing nonrigid ICP
            model = nricp(source, target, 'epsilon', 1e-3, ...
                'is_detail', false);
            %save(mat_file, 'model');
            fprintf('\n');
        end

        function showGraphModels(obj)
            % Visualize all models one by one
            colorGCA = [7 54 66]/255;
            colorModel = [38 139 210]/255;
            
            figure
            for i = 1:obj.num_nodes
                show_model(obj.nodes{i}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
                    'MarkerSize', 20, 'isAnchor', true, 'isLattice', true)
                title(sprintf('Node %d', i));
                hold off
                pause
            end       
        end
    end
end
