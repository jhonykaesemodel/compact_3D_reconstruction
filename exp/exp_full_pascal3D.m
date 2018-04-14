add_paths;
data_paths;

%class = 'chair';
%class = 'sofa';
%class = 'bus';
class = 'aeroplane';
%class = 'bicycle';
%class = 'car';
%class = 'motorbike';
%class = 'diningtable';

class_uid = class2uid(class);

if ~exist('fgraph', 'var')
    fgraph = create_graph(class_uid);
elseif ~strcmp(fgraph.class_uid, class_uid)
    fgraph = create_graph(class_uid);
end

error_rotation = [];
error_structure = [];
isSave = false;
isShow = false;
isIoU = true;

colorGCA = [7 54 66]/255;
colorModel = [38 139 210]/255;

% load natural images from Pascal3D+
disp('Loading Pascal images... ')
filenames = get_pascal_images(class);

for ifilename = 1:numel(filenames)
    filename = filenames{ifilename};
    fprintf('Working on %s \n', filename);
    
    data_paths;
    if ~exist(Result_dir, 'dir')
        mkdir(Result_dir);
    end
    
    r_dir = fullfile(Result_dir, class);
    if ~exist(r_dir, 'dir')
        mkdir(r_dir);
    end
    
    result_file = fullfile(r_dir, [filename, '.mat']);
    if ~exist(result_file, 'file')
        
        %% Step 1: Choose the best CAD model by FFD-PnP
        objs = cell(numel(fgraph),1);
        
        % load image
        I = load_pascal3D(class, filename);
        I = I{1};
        
        %figure, imshow(I.image)
        
        start_loop = tic;
        for i = 1:fgraph.num_nodes
            obj = extrinsicsEstimation(I, fgraph);
            setParameters(obj,  'constC', i, ...
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
        
        %% show the deformed models fitting the image
        if isShow
            figure
            for i = 1:fgraph.num_nodes
                if ~isempty(objs{i}.FFD)
                    subplot(1,3,1)
                    show_model(fgraph.nodes{i}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
                        'MarkerSize', 20, 'isAnchor', true, 'isLattice', true)
                    hold off
                    
                    subplot(1,3,2)
                    show_model(objs{i}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
                        'MarkerSize', 20, 'isAnchor', true, 'isLattice', true)
                    hold off
                    
                    subplot(1,3,3)
                    show_landmarks(I, 'model', objs{i}.FFD, ...
                        'projection', objs{i}.projection, 'show_connection', true, 'maskFac', 0);
                    hold off
                    
                    drawnow
                    pause
                end
            end
        end
        
        %% select the best CAD
        %if ~isIoU
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
       % else
            % using IoU (Jaccard)
            [c, idxIoU, JD] = compute_iou(objs, I);
       % end
              
        
        %% show the best CAD model chosen
        if isShow
            figure
            subplot(1,3,1)
            show_model(fgraph.nodes{c}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
                'MarkerSize', 20, 'isAnchor', true, 'isLattice', true)
            
            subplot(1,3,2)
            show_model(objs{c}.FFD, 'FaceColor', colorModel, 'ColorGCA', colorGCA, ...
                'MarkerSize', 20, 'isAnchor', true, 'isLattice', true)
            
            subplot(1,3,3)
            show_landmarks(I, 'model', objs{c}.FFD, ...
                'projection', objs{c}.projection, 'show_connection', true, 'maskFac', 0);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Step 2: Refine using silhouette info
        isFFD = true;
        sfit = SilhouetteFitting(I, objs{c}.projection, c, fgraph, objs{c}, isFFD);
        sfit.set_param('mu', 0.2, 'L2rho', 1e3, ...
            'obj_tol', 1e-7, 'max_iters', 3e3, ...
            'is_CamUPDA', true, ...
            'is_OmeUPDA', true);
        [projection_sf, model_sf] = sfit.run;
        
       % save('car_noFFD_sf.mat', 'projection_sf', 'model_sf');
        
        %% show results
        if isShow
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
        end

        % eval results
        theta = 0.1;
        [errR, errS] = eval_result(I, fgraph.nodes{c}, projection_sf, theta); % TODO
        
%         result = [];
%         result.I = I;
%         result.c = c;
%         result.idxIoU = idxIoU;
%         result.c_rep = c_rep;
%         result.projection = projection_sf;
%         result.sfit = sfit;
%         result.model = model_sf;
%         result.errR = errR;
%         result.errS = errS;
%         result.obj = objs{c};
        
        % for the DL experiments
        result = [];
        result.I_filename = I.filename;
        result.c = c;
        result.model = model_sf;
        result.deltaP = objs{c}.FFD.deltaP;
                
        error_rotation = [error_rotation, errR];
        error_structure = [error_structure, errS];
        
        % save results
        fprintf('Save results to file %s\n', result_file);
        save(result_file, 'result');
        
        ifilename
        
    else
        continue;
    end
end

error_file = fullfile(Result_dir, [class, '.mat']);
save(error_file, 'error_rotation', 'error_structure');
