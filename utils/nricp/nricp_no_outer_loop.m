function model = nricp_no_outer_loop(model, modelRef, varargin)
% Perform non-rigid ICP (optimizing over affine transformations with Laplacian regularization)
% "Optimal Step Nonrigid ICP Algorithms for Surface Registration", CVPR 2007

warning off;
ip = inputParser;
addOptional(ip, 'alpha', 20, @isnumeric); % stiffness weight ? influences the flexibility of the template
addOptional(ip, 'beta', 1, @isnumeric);   % Default: 1. landmark weight ? is used to fade out the importance of the potentially noisy landmarks towards the end of the registration process
addOptional(ip, 'maxIterN', 20, @isnumeric);
addOptional(ip, 'alphaRelaxRatio', 0.8, @isnumeric);
addOptional(ip, 'gamma', 0.1, @isnumeric); % can be used to weight differences in the rotational and skew part of the deformation against the translational part of the deformation
addOptional(ip, 'epsilon', 1e-4, @isnumeric);
addOptional(ip, 'is_detail', true, @islogical);
parse(ip, varargin{:});
option = ip.Results;

% generate Laplacian matrix
[~,M] = gen_laplacian_matrix(model.mesh);
% initialize variables
vtxN = length(model.vtx);
vtxTraj = zeros(size(model.vtx));

% kdtree
kdtree = KDTreeSearcher(modelRef.vtx);
% Set matrix G (equation (3) in Amberg et al.)
G = diag([1 1 1 option.gamma]);
% Precompute kronecker product of M and G
kron_M_G = kron(M, G);
W = speye(vtxN);
kron_vtxN_ones = kron([1:vtxN]',ones(4,1));
vtxN_list = [1:vtxN*4]';
spalloc_M = spalloc(size(M,1)*4, 3, 0);

hist_it = 1;

tic;
% optimize over x
while true
    % find correspondence: closest points
    [U,~] = surf_projection(model, modelRef, kdtree);
    projDist = sum(sqrt(sum((model.vtx - U).^2,2)));
    % enforce landmark correspondences
    U(model.anchor,:) = modelRef.vtx(modelRef.anchor,:);
    Ddata = [model.vtx, ones(vtxN,1)]';
    D = sparse(kron_vtxN_ones, vtxN_list, Ddata(:));
    DL = D(model.anchor,:);
    UL = U(model.anchor,:);
    A = [option.alpha*kron_M_G; W*D; option.beta*DL];
    B = [spalloc_M; W*U; option.beta*UL];
    Xaff = A\B;
    % update
    model.vtx = full(D*Xaff);
    updateDist = sum(sqrt(sum((model.vtx - vtxTraj).^2,2)))/vtxN;
    vtxTraj = model.vtx;
    if option.is_detail
        fprintf(' alpha=%f, projDist=%f, updateDist=%f, time=%fsec\n',...
            option.alpha,projDist,updateDist,toc);
    else
        fprintf('.');
    end
    
    hist_vtx{hist_it,1} = model.vtx;
    
    hist_it = hist_it + 1;
    
    if updateDist < option.epsilon
        break;
    end
end
model.hist_vtx = hist_vtx;
warning on;
