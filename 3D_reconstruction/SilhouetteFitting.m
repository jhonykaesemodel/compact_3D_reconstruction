classdef SilhouetteFitting < handle
    % The class to execute silhouette fitting

    properties(GetAccess = 'public', SetAccess = 'private')
        % known variables
        sg;             % segmentation
        c_dist;         % Chamfer distance
        vertices;       % vertices dictionary
        connected_nodes;% the nodes connected from c-th node
        projection;     % the projection
        anchors;        % the index of vertices which is considered as landmark
        W;              % the 2D landmarks detected on image
        I;              % the 2D image

        % unknown variables
        omega;          % the weight of each connected nodes
        omega_history;  % the history of changes of omega
        model;          % For output.
        proj_history;   % the history of changes of projection

        % parameters
        mu;             % the weight of penalty term
        dist_weight;    % Weights for Chamfer distance
        max_iters;      % the maximum number of iterations
        obj_tol;        % the tolerance of objective change
        is_detail;      % to print details or not
        alpha;          % parameters in backtracking
        beta;           % parameters in backtracking

        % inner parameters
        gradient;       % the number indicate which model is active
        t;              % step size
        proj_err;       % the reprojection error
        penalty;        % the penalty term
        cost;           % objective record
        dcost;          % objective change
        idle_its;       % Output per 'idel_its' iterations.

        % exprement control
        L2rho;          % penalty of L2 norm regularization
        is_CamUPDA;     % indicator of updating projection or not
        is_OmeUPDA;     % indicator of updating omega or not
    end

    methods
        function obj = SilhouetteFitting(I, projection, c, fgraph, objFFD, isFFD)
            % Initialize Silhouette fitting
            mask = (~isnan(I.anchors(:, 1))&(fgraph.nodes{c}.anchor~=0)');
            % adjust from image coor
            obj.W = im2xy(I.anchors(mask, :)', size(I.image));
            obj.I = I;
            obj.sg = flipud(I.segmentation);
            obj.connected_nodes = find(fgraph.edges(c, :));
            obj.vertices = cell(1+numel(obj.connected_nodes), 1);
            
            if isFFD
                obj.vertices{1} = objFFD.FFD.vtx; % deformed FFD
            else
                obj.vertices{1} = fgraph.nodes{c}.FFD.vtx; % original FFD
            end

            for inode = 1:numel(obj.connected_nodes)
                model = fgraph.deform_model(c, obj.connected_nodes(inode));      
                % normalize model
                vtx_diff = bsxfun(@minus, objFFD.FFD.vtx', model.vtx');
                mean_diff = mean(vtx_diff,2);
                vtx_norm = bsxfun(@plus, model.vtx', mean_diff);
                obj.vertices{inode+1} = vtx_norm';
            end
            obj.projection = projection;
            obj.anchors = fgraph.nodes{c}.anchor(:, mask);
            obj.model = struct('vtx', obj.vertices{1}, ...
                'mesh', fgraph.nodes{c}.mesh, ...
                'nodes', [c, obj.connected_nodes], ...
                'weight', obj.omega, ...
                'anchor', fgraph.nodes{c}.anchor);
        end

        function set_param(obj, varargin)
            % Set parameters for gradient descent algorithm
            ip = inputParser;
            addOptional(ip, 'mu', 1e-2, @isnumeric);
            addOptional(ip, 'dist_weight', [1, sqrt(2)], @isnumeric);
            addOptional(ip, 'max_iters', 1e4, @isnumeric);
            addOptional(ip, 'obj_tol', 1e-7, @isnumeric);
            addOptional(ip, 'is_detail', true, @islogical);
            addOptional(ip, 'alpha', 0.5, @isnumeric);
            addOptional(ip, 'beta', 0.5, @isnumeric);
            addOptional(ip, 'idle_its', 20, @isnumeric);
            addOptional(ip, 'L2rho', 0, @isnumeric);
            addOptional(ip, 'is_CamUPDA', true, @islogical);
            addOptional(ip, 'is_OmeUPDA', true, @islogical);
            parse(ip, varargin{:}); 
            obj.mu = ip.Results.mu;
            obj.dist_weight = ip.Results.dist_weight;
            obj.max_iters = ip.Results.max_iters;
            obj.obj_tol = ip.Results.obj_tol;
            obj.is_detail = ip.Results.is_detail;
            obj.alpha = ip.Results.alpha;
            obj.beta = ip.Results.beta;
            obj.idle_its = ip.Results.idle_its;
            obj.L2rho = ip.Results.L2rho;
            obj.is_CamUPDA = ip.Results.is_CamUPDA;
            obj.is_OmeUPDA = ip.Results.is_OmeUPDA;

            % initialize with parameters
            obj.c_dist = imChamferDistance(obj.sg, obj.dist_weight);
            obj.cost = 0;
            obj.omega = [1; zeros(numel(obj.connected_nodes), 1)];
            obj.cost = 0;
            obj.dcost = inf;
            obj.omega_history = nan(numel(obj.omega), obj.max_iters+1);
            obj.omega_history(:, 1) = obj.omega;
            obj.proj_history = cell(obj.max_iters+1);
            obj.proj_history{1} = obj.projection;
        end

        function [projection, model] = run(obj)
            % Run the main algorithm
            %
            %   weight = obj.run()
            %
            tic;
            if obj.is_detail
                obj.output(-1);
            end
            for i = 1:obj.max_iters
                obj.compute_gradient;
                obj.backtracking;
                obj.omega_history(:, i+1) = obj.omega;
                obj.proj_history{i+1} = obj.projection;
                if obj.is_detail
                    if mod(i, obj.idle_its) == 0
                        obj.output(i);
                    elseif i == 1
                        obj.output(i);
                    end
                end
                if obj.is_stop
                    obj.output(i);
                    break;
                end
            end
            V = obj.omega(1)*obj.vertices{1};
            for i = 2:numel(obj.omega)
                V = V + obj.omega(i)*obj.vertices{i};
            end
            obj.model.vtx = V;
            obj.model.weight = obj.omega;
            model = obj.model;
            projection = obj.projection;
        end

        function compute_gradient(obj)
            % Compute the gradient

            % Compute combined vertices with current weight
            % V is P-by-3 matrix
            % X is P-by-3 matrix
            V = obj.omega(1)*obj.vertices{1};
            for i = 2:numel(obj.omega)
                V = V + obj.omega(i)*obj.vertices{i};
            end
            X = V(obj.anchors, :);

            % Compute 2D projection of all vertices
            % U is 2-by-P matrix
            Ux = bsxfun(@plus, obj.projection.scale*obj.projection.rotation*...
                X', obj.projection.translation);
            Uv = bsxfun(@plus, obj.projection.scale*obj.projection.rotation*...
                V', obj.projection.translation);

            % Compute Delta C
            [~, visibleSet] = find(...
                (Uv(1, :) < size(obj.c_dist, 2) & Uv(1, :) > 1) & ...
                (Uv(2, :) < size(obj.c_dist, 1) & Uv(2, :) > 1));
            Uvv = Uv([2, 1], visibleSet); % remove vertices outsize of the image
            % Use image interpolation
            pixel_sub = floor(Uvv);
            pixel_ind00 = sub2ind(size(obj.c_dist), pixel_sub(1,:),pixel_sub(2,:));
            pixel_ind10 = sub2ind(size(obj.c_dist), pixel_sub(1,:)+1,pixel_sub(2,:));
            pixel_ind01 = sub2ind(size(obj.c_dist), pixel_sub(1,:), pixel_sub(2,:)+1);
            pixel_ind11 = sub2ind(size(obj.c_dist), pixel_sub(1,:)+1, pixel_sub(2,:)+1);
            A00 = obj.c_dist(pixel_ind00);
            A10 = obj.c_dist(pixel_ind10) - obj.c_dist(pixel_ind00);
            A01 = obj.c_dist(pixel_ind01) - obj.c_dist(pixel_ind00);
            A11 = obj.c_dist(pixel_ind11) + obj.c_dist(pixel_ind00) - ...
                (obj.c_dist(pixel_ind10) + obj.c_dist(pixel_ind01));

            deltaC = zeros(2, numel(visibleSet));
            deltaC(2, :) = A10+A11.*(Uvv(2, :) - pixel_sub(2, :));
            deltaC(1, :) = A01+A11.*(Uvv(1, :) - pixel_sub(1, :));

            % Compute gradient w.r.t omega
            gradient_omega = zeros(size(obj.omega));
            if obj.is_OmeUPDA
                for i = 1:numel(obj.omega)
                    gradient_omega(i) = sum(sum(obj.projection.scale*((Ux - obj.W)' * ...
                        obj.projection.rotation) .* obj.vertices{i}(obj.anchors, :))) + ...
                        obj.mu* sum(sum(obj.projection.scale*(deltaC'* ...
                        obj.projection.rotation).* obj.vertices{i}(visibleSet, :)));
                end
                if obj.L2rho
                    gradient_omega(2:end) = gradient_omega(2:end) + ...
                        obj.L2rho*obj.omega(2:end);
                end
            end

            % Compute gradient w.r.t xi
            gradient_xi = zeros(3, 1);
            if obj.is_CamUPDA
                ele_xi{1} = [0, 0, 0; 0, 0, -1; 0, +1, 0];
                ele_xi{2} = [0, 0, +1; 0, 0, 0; -1, 0, 0];
                ele_xi{3} = [0, -1, 0; +1, 0, 0; 0, 0, 0];
                for i = 1:3
                    gradient_xi(i) = sum(sum((Ux - obj.W) .* (obj.projection.scale*...
                        obj.projection.rotation*ele_xi{i}*X'))) + ...
                        obj.mu*sum(sum(deltaC.* (obj.projection.scale*...
                        obj.projection.rotation*ele_xi{i}*V(visibleSet, :)')));
                end
            end

            % Compute gradient w.r.t t
            if obj.is_CamUPDA
                gradient_t = sum(Ux - obj.W, 2) + obj.mu*sum(deltaC, 2);
            else
                gradient_t = zeros(2, 1);
            end

            obj.gradient = [gradient_xi; gradient_t; gradient_omega];
        end

        function backtracking(obj)
            % Use backtracking to decide step size
            obj.t = 1e-4/obj.beta;
            obj.compute_cost;
            proj_bk = obj.projection;
            omega_bk = obj.omega;
            xi2mat = @(x) expm([0, -x(3), x(2); x(3), 0, -x(1); -x(2), x(1), 0]);
            pcost = obj.cost;
            while obj.dcost > - obj.alpha*obj.t*norm(obj.gradient)^2
                obj.cost = pcost;
                obj.t = obj.t*obj.beta;
                obj.projection.rotation = ...
                    proj_bk.rotation*xi2mat(-obj.t*obj.gradient(1:3));
                obj.projection.translation = ...
                    proj_bk.translation - obj.t*obj.gradient(4:5);
                obj.omega = omega_bk - obj.t*obj.gradient(6:end);
                obj.compute_cost;
            end
        end

        function compute_cost(obj)
            % Compute objective value
            %

            % Compute re-projection error
            V = obj.omega(1)*obj.vertices{1};
            for i = 2:numel(obj.omega)
                V = V + obj.omega(i)*obj.vertices{i};
            end
            X = V(obj.anchors, :);
            Ux = bsxfun(@plus, obj.projection.scale*obj.projection.rotation*...
                X', obj.projection.translation);
            Uv = bsxfun(@plus, obj.projection.scale*obj.projection.rotation*...
                V', obj.projection.translation);
            obj.proj_err = norm(Ux - obj.W, 'fro')^2;

            % Compute silhouette penalty
            [~, visibleSet] = find(...
                (Uv(1, :) < size(obj.c_dist, 2) & Uv(1, :) > 1) & ...
                (Uv(2, :) < size(obj.c_dist, 1) & Uv(2, :) > 1));
            Uvv = Uv([2, 1], visibleSet); % remove vertices outsize of the image
            % Use image interpolation
            pixel_sub = floor(Uvv);
            pixel_ind00 = sub2ind(size(obj.c_dist), pixel_sub(1,:),pixel_sub(2,:));
            pixel_ind10 = sub2ind(size(obj.c_dist), pixel_sub(1,:)+1,pixel_sub(2,:));
            pixel_ind01 = sub2ind(size(obj.c_dist), pixel_sub(1,:), pixel_sub(2,:)+1);
            pixel_ind11 = sub2ind(size(obj.c_dist), pixel_sub(1,:)+1, pixel_sub(2,:)+1);
            A00 = obj.c_dist(pixel_ind00);
            A10 = obj.c_dist(pixel_ind10) - obj.c_dist(pixel_ind00);
            A01 = obj.c_dist(pixel_ind01) - obj.c_dist(pixel_ind00);
            A11 = obj.c_dist(pixel_ind11) + obj.c_dist(pixel_ind00) - ...
                (obj.c_dist(pixel_ind10) + obj.c_dist(pixel_ind01));

            obj.penalty = sum(A00 + A10.*(Uvv(1, :) - pixel_sub(1, :)) + ...
                A01.*(Uvv(2, :) - pixel_sub(2, :)) + ...
                A11.*(Uvv(1, :) - pixel_sub(1, :)).*(Uvv(2, :) - pixel_sub(2, :)));

            % Compute objective
            pcost = obj.cost;
            if obj.L2rho
                obj.cost = 1/2*obj.proj_err + obj.mu*obj.penalty + ...
                    obj.L2rho/2*sum(obj.omega(2:end).^2);
            else
                obj.cost = 1/2*obj.proj_err + obj.mu*obj.penalty;
            end
            obj.dcost = obj.cost - pcost;
        end

        function output(obj, iter)
            % Output information to screen
            if iter == -1
                prop = {'it', 'step_size', 'proj_err', ...
                    'penalty', 'Omg_norm', 'cost', 'd(cost)', 'time'};
                num_prop = numel(prop);
                fprintf('Using gradient descent to fit silhouette.\n');
                fprintf('%s\n', repmat('*', 1, num_prop*10));
                fprintf(repmat('%10s', 1, num_prop), prop{:});
                fprintf('\n');
                fprintf('%s\n', repmat('-', 1, num_prop*10));
            else
                fprintf('%10d%10.2e%10.2e%10.2e%10.2e%10.2e%10.2e%10.2e\n', ...
                    iter, obj.t, obj.proj_err, obj.penalty, ...
                    sum(obj.omega(2:end).^2), obj.cost, obj.dcost, toc);
            end
        end

        function bool = is_stop(obj)
            % Decide to stop or not
            is_obj_tol = abs(obj.dcost) < obj.obj_tol*obj.cost;
            is_descent = obj.dcost < 0;
            bool = is_obj_tol && is_descent;
        end

        function test_gradient(obj, delta)
            % The function to test if the gradient is computed properly
            %   This function is only used for debugging. Never run this during
            %   any job as this function will add small perturbation to
            %   variables.
            %
            %   obj.test_gradient()
            %
            if nargin < 2
                delta = 1e-6;
            end
            xi2mat = @(x) expm([0, -x(3), x(2); x(3), 0, -x(1); -x(2), x(1), 0]);
            obj.compute_cost;
            for i = 1:3
                xi = zeros(3, 1);
                xi(i) = delta;
                obj.projection.rotation = ...
                    obj.projection.rotation*xi2mat(xi);
                obj.compute_gradient;
                obj.compute_cost;
                fprintf(['The derivative is %.4e approximately, and the', ...
                    'computed gradient is %.4e\n'], obj.dcost/delta, ...
                    obj.gradient(i));
            end

            for i = 1:2
                obj.projection.translation(i) = ...
                    obj.projection.translation(i) + delta;
                obj.compute_gradient;
                obj.compute_cost;
                fprintf(['The derivative is %.4e approximately, and the', ...
                    'computed gradient is %.4e\n'], obj.dcost/delta, ...
                    obj.gradient(i+3));
            end

            for i = 1:numel(obj.vertices)
                obj.omega(i) = obj.omega(i) + delta;
                obj.compute_gradient;
                obj.compute_cost;
                fprintf(['The derivative is %.4e approximately, and the', ...
                    'computed gradient is %.4e\n'], obj.dcost/delta, ...
                    obj.gradient(i+5));
            end
        end

        function viz_process2d(obj, idle_its)
            % Show the process of model's deformation
            if nargin < 2
                idle_its = obj.idle_its;
            end
            figure;
            display_model = obj.model;
            num_iter = find(isnan(sum(obj.omega_history, 1)), 1) - 1;
            if isempty(num_iter)
                num_iter = obj.max_iters;
            end
            for i = 1:idle_its:num_iter
                V = obj.omega_history(1, i)*obj.vertices{1};
                for j = 2:size(obj.omega_history, 1)
                    V = V + obj.omega_history(j, i)*obj.vertices{j};
                end
                display_model.vtx = V;
                subplot(1, 2, 1)
                hold off;
                draw_landmarks(obj.I, 'model', display_model, 'projection', ...
                    obj.proj_history{i});
                subplot(1, 2, 2)
                plot(obj.omega_history(:, 1:i)');
                pause;
            end
        end
    end
end
