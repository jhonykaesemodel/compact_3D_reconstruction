function [source, dP, Phat, hist_deltaP] = alignment_FFD_3D(obj, i, j, varargin)

ip = inputParser;
addOptional(ip, 'isCVX', true);
addOptional(ip, 'showDeformation', false);
addOptional(ip, 'showLattice', false);
parse(ip, varargin{:});
option = ip.Results;

source = obj.nodes{i};
target = obj.nodes{j};

mask = ((source.anchor~=0)&(target.anchor~=0));
source.anchor = source.anchor(mask);
target.anchor = target.anchor(mask);

%% deform the source landmarks to fit the target landmarks by FFD
% initialize variables
% source
P = source.FFD.P;
B = source.FFD.B;
Banch = B(source.anchor,:);
Bkron = mykron(Banch, eye(3));

%% normalize source & target
% normalize FFD source
vtx_diff = bsxfun(@minus, source.FFD.vtx', source.vtx');
mean_diff = mean(vtx_diff,2);
vtx_norm = bsxfun(@plus, target.vtx', mean_diff);
target.vtx = vtx_norm';

% target FFD
vecV_target = vec(target.vtx(target.anchor,:)');

% compute the matrix to impose symmetry
if isequal(obj.class_uid, '04379243') % dining table is mostly symmetric in x and y
    phi = symmetric_matrix(P, target.FFD.l, target.FFD.m, target.FFD.n, true);
else
    phi = symmetric_matrix(P, target.FFD.l, target.FFD.m, target.FFD.n);
end

%% solve by CVX or Gradint Descent
if option.isCVX
%% deform source to target by FFD using CVX
    lambda = 0.15;
    cvx_begin quiet
        variable dP(64,3);
        minimize(norm(vecV_target - Bkron*(vec(P') + phi*vec(dP')), 'fro') + lambda*norm(phi*vec(dP')))
    cvx_end
   
    dP = vec2mat(phi*vec(dP'),3);
    
    % plot
    Phat = P + dP;
    Shat = B*Phat;
    sourceDef = source;
    sourceDef.FFD.vtx = Shat;
    sourceDef.FFD.Phat = Phat;
    
%     figure
%     show_model(sourceDef.FFD, 'FaceColor', colorModelTarget, 'ColorGCA', colorGCA, ...
%         'MarkerSize', 20, 'lighting', true, 'isLattice', true, 'isAnchor', true);
% 
%     figure
%     plot3(target.vtx(target.anchor,1), target.vtx(target.anchor,2), target.vtx(target.anchor,3), 'b.')
%     hold on
%     plot3(Shat(source.anchor,1), Shat(source.anchor,2), Shat(source.anchor,3), 'ro')
%     axis equal  
else
%% deform source to target by FFD using gradient descent
% gradient descent parametes
max_iter = 10e3;    % maximum number of iterations
step = 1e-3;        % step size for gradient descent 1e-1
obj_tol = 1e-6;     % tolerance of objective change
idle_iter = 20;     % show info after n iterations
lambda = 1e-2;      % weight for the L2 regularization 1e-3

isBacktracking = true;
alpha = 0.5;        % step size for gradient descent
beta = 0.5;         % step size for gradient descent

% initialize variables
deltaP = zeros(size(P));
Shat = B*P;
cost = zeros(max_iter,1);
prev_cost = inf;
dcost = inf;
sourceDef = source; % for plotting

% vectorize variables
% source FFD
vec_Pt = vec(P');
vec_deltaPt = zeros(size(vec_Pt));

% function handle for the objective function
f = @(x) 0.5*norm(vecV_target - (Bkron * (vec_Pt + phi*x)), 'fro')^2;

if option.showDeformation
    fig = figure;
    set(gcf, 'Position', get(0, 'Screensize'));
    colorGCA = [7 54 66]/255;
    colorModelSource = [220 50 47]/255;
    
    sourceDef.FFD.Phat = P;
    [h, h_anch, hLines, h_latt] = show_model(sourceDef.FFD, 'FaceColor', colorModelSource, 'ColorGCA', colorGCA, ...
        'MarkerSize', 20, 'lighting', true, 'isLattice', option.showLattice, 'isAnchor', true, ...
        'FaceAlpha', 0.5, 'MarkerSize', 40, 'AnchorColor', 'r', 'AnchorMarker', '.');
    
    hold on
    colorModelTarget = [38 139 210]/255;
    [~, h_anch_T, ~, ~] = show_model(target, 'FaceColor', colorModelTarget, 'ColorGCA', colorGCA, ...
        'MarkerSize', 20, 'lighting', true, 'isLattice', false, 'isAnchor', true, ...
        'FaceAlpha', 0.3, 'MarkerSize', 30, 'AnchorColor', 'b', 'AnchorMarker', '.');
    
    lgd = legend([h_anch, h_anch_T], {'Source','Target'}, 'Location', 'best');
    lgd.TextColor = [0 43 54]/255;
    lgd.Color = [253 246 227]/255;
    title('Deforming the Source anchors to fit the Target anchors by FFD')
end

% perform gradient descent
tic
for iter = 1:max_iter
    % gradient w.r.t vec_deltaPt
    grad_deltaPt = ((vecV_target - (Bkron*(vec_Pt + phi*vec_deltaPt)))' * Bkron*phi)' + lambda*(phi*vec_deltaPt);
    
     % line search backtracking
     if isBacktracking
         step = 1e-3/beta;
         vec_deltaPt = vec_deltaPt + step*grad_deltaPt;
         cost(iter) = f(vec_deltaPt);
         while f(vec_deltaPt - step*grad_deltaPt) > f(vec_deltaPt) - alpha*step*norm(grad_deltaPt)^2
             step = beta*step;
             vec_deltaPt = vec_deltaPt + step*grad_deltaPt;
             cost(iter) = f(vec_deltaPt);
         end
     else
         vec_deltaPt = vec_deltaPt + step*grad_deltaPt;
     end
    
    % compute cost
    cost(iter) = f(vec_deltaPt) + lambda/2*norm(phi*vec_deltaPt,'fro')^2;
    dcost = cost(iter) - prev_cost;
    prev_cost = cost(iter);
    
    % stop criterion
    if (abs(dcost) < obj_tol*cost(iter)) && (dcost < 0)
        break
    end
    
    % show info
    if iter == 1
        fprintf('Iter: %d, Step: %.2e, Obj: %.6f \n', iter, step, cost(iter));
    elseif mod(iter, idle_iter) == 0
        fprintf('Iter: %d, Step: %.2e, Obj: %.6f \n', iter, step, cost(iter));
    end
    
    % update the FFD
    deltaP = vec2mat(phi*vec_deltaPt,3);
    Phat = P + deltaP;
    Shat = B*Phat;
    
    hist_deltaP{iter} = deltaP;
    
    if option.showDeformation && (mod(iter, idle_iter) == 0)
        %pause
        idle_iter = 10;
        % update data
        sourceDef.FFD.vtx = Shat;
        sourceDef.FFD.Phat = Phat;
        
        % update vertices
        set(h, 'Vertices', sourceDef.FFD.vtx);
        % update anchors
        x = sourceDef.FFD.vtx(sourceDef.anchor(sourceDef.anchor~=0), 1);
        y = sourceDef.FFD.vtx(sourceDef.anchor(sourceDef.anchor~=0), 2);
        z = sourceDef.FFD.vtx(sourceDef.anchor(sourceDef.anchor~=0), 3);
        set(h_anch,'XData',x,'YData',y,'ZData', z);
        
        % uddate lattice
        if option.showLattice
            update_FFD_lattice(Phat, sourceDef.FFD.l, sourceDef.FFD.m, ...
                sourceDef.FFD.n, hLines, h_latt);
        end
        
        drawnow;
        
        % pause(0.01)
    end
end
t_grad = toc;

dP = vec2mat(phi*vec_deltaPt,3);

%% plot cost function curve
% figure
% plot(1:iter, cost(1:iter), 'LineWidth',2);
% title('Objective Function'); xlabel('Iteration'); ylabel('F(x)');
end

%% FFD data
Phat = P + dP;
vtx_def = B*Phat;

% get FFD vertices deformed
source.vtx = vtx_def;

% figure
% plot3(target.vtx(target.anchor,1), target.vtx(target.anchor,2), target.vtx(target.anchor,3), 'b.')
% hold on
% plot3(Shat(source.anchor,1), Shat(source.anchor,2), Shat(source.anchor,3), 'ro')
% axis equal
