classdef ExtrinsicsEstimation < handle

    properties(GetAccess = 'public', SetAccess = 'private')
        % known variables
        W;              % 2D landmarks
        num_points;     % the number of points
        FFD;            % 3D landmarks from dictionary (B and P from FFD)
        phi;            % matrix to enforce symmetry on the lattice P

        % unknown variables
        M;              % camera rotation*scale
        Z;              % auxiliary variable
        Lambda;         % the lagrangian variable
        t;              % the rotation
        c;              % the number indicate which model is active

        % parameters
        rho;            % penalty for ||M-Z||
        rate_rho;       % rate to increase rho
        max_rho;        % the maximum value of rho
        max_iters;      % the maximum number of iterations
        obj_tol;        % the tolerance of objective
        dobj_tol;       % the tolerance of objective change
        is_detail;      % to print details or not
        is_normalize;   % to normalize W or not
        constC;         % if 0, auto update c; otherwise fix c as constC
        gamma;          % L2 penalty for deltaP

        % inner parameters
        cost;           % objective record
        dist_MZ;        % distance between M and Z
        proj_err;       % reprojection error
        dcost;          % objective change
    end

    methods
        function obj = ExtrinsicsEstimation(I, fgraph)
            mask = (~isnan(I.anchors(:, 1)));
            % adjust from image coordinates
            obj.W = im2xy(I.anchors(mask, :)', size(I.image));
            obj.num_points = size(obj.W, 2);
            obj.FFD = cell(fgraph.num_nodes, 1);
            for i = 1:fgraph.num_nodes
                %mask = (fgraph.nodes{i}.anchor~=0) & (~isnan(I.anchors(:, 1)))';
                if isempty(find(fgraph.nodes{i}.anchor(mask)==0, 1))
                    obj.FFD{i}.Banch = fgraph.nodes{i}.FFD.B(fgraph.nodes{i}.anchor(mask), :)';
                    obj.FFD{i}.P = fgraph.nodes{i}.FFD.P;
                    obj.FFD{i}.deltaP = zeros(size(obj.FFD{i}.P));
                    obj.FFD{i}.B = fgraph.nodes{i}.FFD.B;
                    obj.FFD{i}.mesh = fgraph.nodes{i}.FFD.mesh;
                    obj.FFD{i}.anchor = fgraph.nodes{i}.FFD.anchor;
                    obj.FFD{i}.l = fgraph.nodes{i}.FFD.l;
                    obj.FFD{i}.m = fgraph.nodes{i}.FFD.m;
                    obj.FFD{i}.n = fgraph.nodes{i}.FFD.n;
                else
                    obj.FFD{i}.Banch = [];
                    obj.FFD{i}.P = [];
                    obj.FFD{i}.deltaP = [];
                    obj.FFD{i}.B = [];
                    obj.FFD{i}.mesh = [];
                    obj.FFD{i}.anchor = [];
                    obj.FFD{i}.l = [];
                    obj.FFD{i}.m = [];
                    obj.FFD{i}.n = [];
                end
            end
            
            % initialize symmetric matrix for FFD
            l = fgraph.nodes{1}.FFD.l; 
            m = fgraph.nodes{1}.FFD.m; 
            n = fgraph.nodes{1}.FFD.n;
            P = fgraph.nodes{1}.FFD.P;
            
            if isequal(fgraph.class_uid, '04379243') % dining table is mostly symmetric in x and y
                obj.phi = symmetric_matrix(P, l, m, n, true);
            else
                obj.phi = symmetric_matrix(P, l, m, n);
            end            

            % initialize unknown variables
            obj.M = [1, 0, 0; 0, 1, 0];
            obj.Z = obj.M;
            obj.Lambda = zeros(2, 3);
            obj.t = zeros(2, 1);
            obj.cost = 0;
        end

        function setParameters(obj, varargin)
            ip = inputParser;
            addOptional(ip, 'rho', 1e-2, @isnumeric);
            addOptional(ip, 'rate_rho', 1.01, @isnumeric);
            addOptional(ip, 'max_rho', 1e5, @isnumeric);
            addOptional(ip, 'max_iters', 1e3, @isnumeric);
            addOptional(ip, 'obj_tol', 1e-7, @isnumeric);
            addOptional(ip, 'dobj_tol', 1e-7, @isnumeric);
            addOptional(ip, 'is_detail', true, @islogical);
            addOptional(ip, 'is_normalize', true, @islogical);
            addOptional(ip, 'constC', 0, @isnumeric);
            addOptional(ip, 'randInit', false, @islogical);
            addOptional(ip, 'gamma', 0, @isnumeric);
            parse(ip, varargin{:}); 
            obj.rho = ip.Results.rho;
            obj.rate_rho = ip.Results.rate_rho;
            obj.max_rho = ip.Results.max_rho;
            obj.max_iters = ip.Results.max_iters;
            obj.obj_tol = ip.Results.obj_tol;
            obj.dobj_tol = ip.Results.dobj_tol;
            obj.is_detail = ip.Results.is_detail;
            obj.is_normalize = ip.Results.is_normalize;
            obj.constC = ip.Results.constC;
            obj.gamma = ip.Results.gamma;

            if ip.Results.randInit
                randMat = randn(3);
                [U, ~, V] = svd(randMat);
                randRot = U*V';
                obj.M = randn(1)*randRot(1:2, :);
                obj.Z = obj.M;
            end
            
            if ~obj.constC
                obj.c = randsample(find(cellfun(@isempty, obj.FFD)==0), 1);
            else
                obj.c = obj.constC;
            end
            
        end

        function [projection, c] = run(obj)
            tic;
            if obj.is_normalize
                [mean_proj, std_proj] = obj.normalize_W();
            end
            obj.output(-1);
            for i = 1:obj.max_iters
                obj.update_Z;
                obj.update_M;
                obj.update_deltaP;
                obj.update_t;
                obj.update_lag;
                obj.update_penalty;
                obj.compute_cost;
                obj.output(i);
                if obj.is_stop
                    obj.output(i);
                    break;
                end
            end
            [U, S, V] = svd(obj.M, 'econ');
            projection.rotation = U*V';
            projection.scale = (S(1, 1) + S(2, 2))/2;
            projection.translation = obj.t;
            c = obj.c;
            if obj.is_normalize
                projection.scale = projection.scale*std_proj;
                projection.translation = projection.translation*std_proj + mean_proj;
            end
        end

        function [mean_proj, std_proj] = normalize_W(obj)
            mean_proj = sum(obj.W, 2)/size(obj.W, 2);
            obj.W = bsxfun(@minus, obj.W, mean_proj);
            std_proj = mean(std(obj.W, 1, 2));
            obj.W = obj.W/std_proj;
        end

        function update_Z(obj)
            % compute S
            P = obj.FFD{obj.c}.P';
            Banch = obj.FFD{obj.c}.Banch;
            deltaP = obj.FFD{obj.c}.deltaP;
            vec_deltaP = obj.phi * vec(deltaP);
            phi_deltaP = vec2mat(vec_deltaP,3)';
            S = (P + phi_deltaP) * Banch;
            
            % update Z
            w_minus_t = bsxfun(@minus, obj.W, obj.t);
            left = w_minus_t*S' + obj.Lambda + obj.rho*obj.M;
            right = S*S' + obj.rho*eye(3);      
            obj.Z = left/right;
        end

        function update_M(obj)
            % Update M
            [U, S, V] = svd(obj.Z - obj.Lambda/obj.rho, 'econ');
            mean_sv = (S(1, 1) + S(2, 2))/2;
            obj.M = U*[mean_sv, 0; 0 , mean_sv]*V';
        end

        function update_deltaP(obj)
            % vectorize everything because of the symmetric matrix
            vec_W = vec(obj.W);
            vec_P = vec(obj.FFD{obj.c}.P');
            BkronZ = mykron(obj.FFD{obj.c}.Banch', obj.Z);
            T = repmat(obj.t', 1, size(obj.W,2))';
            
            % update deltaP
            right = (BkronZ*obj.phi)'*(vec_W - (BkronZ*vec_P + T));
            left = ((BkronZ*obj.phi)'*BkronZ*obj.phi + obj.gamma*obj.phi);
            
            vec_deltaP = pinv(left)*right;
            obj.FFD{obj.c}.deltaP = vec2mat(vec_deltaP,3)';
            
            % save (P + phi*dP)
            obj.FFD{obj.c}.Phat = obj.FFD{obj.c}.P + vec2mat(obj.phi*vec_deltaP,3);
            obj.FFD{obj.c}.vtx = obj.FFD{obj.c}.B * obj.FFD{obj.c}.Phat;
        end
        
        function update_t(obj)
            % compute S
            P = obj.FFD{obj.c}.P';
            Banch = obj.FFD{obj.c}.Banch;
            deltaP = obj.FFD{obj.c}.deltaP;
            vec_deltaP = obj.phi * vec(deltaP);
            phi_deltaP = vec2mat(vec_deltaP,3)';
            S = (P + phi_deltaP) * Banch;
            
            % update t
            obj.t = sum(obj.W - obj.Z*S, 2) / obj.num_points;
        end

        function update_lag(obj)
            % Update lagrangian multiplier
            obj.Lambda = obj.Lambda + obj.rho*(obj.M - obj.Z);
        end

        function update_penalty(obj)
            % Update penalty rho
            if obj.rho < obj.max_rho
                obj.rho = obj.rho*obj.rate_rho;
            end
        end

        function compute_cost(obj)
            % Compute cost
            obj.dist_MZ = norm(obj.M - obj.Z, 'fro')^2;
          
            % compute anchors using FFD dictionary
            P = obj.FFD{obj.c}.P';
            Banch = obj.FFD{obj.c}.Banch;
            deltaP = obj.FFD{obj.c}.deltaP;
            vec_deltaP = obj.phi * vec(deltaP);
            phi_deltaP = vec2mat(vec_deltaP,3)';
            S = (P + phi_deltaP) * Banch;
            
            % reprojection error
            sum_ZS_t = bsxfun(@plus,obj.Z*S, obj.t);
            obj.proj_err = norm(obj.W - sum_ZS_t, 'fro')^2;
            
            % cost function
            cost = 1/2*obj.proj_err + ...
                (obj.gamma/2)*norm(vec_deltaP)^2 + ...
                sum(sum(obj.Lambda.*(obj.M - obj.Z))) + ...
                obj.rho/2*obj.dist_MZ;
            
            obj.dcost = cost - obj.cost;
            obj.cost = cost;
        end

        function output(obj, iter)
            % Output information to screen
            if iter == -1
                prop = {'iter', 'c', 'rho', '||M-Z||', 'proj_err', 'cost', ...
                    'd(cost)', 'time'};
                num_prop = numel(prop);
                fprintf('ADMM - Alternating Direction Method of Multipliers \n');
                fprintf('%s\n', repmat('-', 1, num_prop*10));
                fprintf(repmat('%10s', 1, num_prop), prop{:});
                fprintf('\n');
                fprintf('%s\n', repmat('-', 1, num_prop*10));
            else
                fprintf('%10d%10d%10.2e%10.2e%10.2e%10.2e%10.2e%10.2e\n', ...
                    iter, obj.c, obj.rho, obj.dist_MZ, obj.proj_err, ...
                    obj.cost, obj.dcost, toc);
            end
        end

        function bool = is_stop(obj)
            % Decide to stop algorithm or not
            is_dobj_tol = abs(obj.dcost) < obj.dobj_tol*obj.cost;
            is_obj_tol = obj.cost < obj.obj_tol;
            is_descent = obj.dcost < 0;
            bool = (is_dobj_tol && is_descent) || is_obj_tol;
        end
    end
end
