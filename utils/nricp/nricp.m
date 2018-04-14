function model = nricp(model, modelRef, varargin)
% Perform non-rigid ICP (optimizing over affine transformations with Laplacian regularization)
% "Optimal Step Nonrigid ICP Algorithms for Surface Registration", CVPR 2007

warning off;
ip = inputParser;
addOptional(ip, 'alpha', 20, @isnumeric); % stiffness weight ? influences the flexibility of the template
addOptional(ip, 'beta', 1, @isnumeric);   % Default: 1. landmark weight ? is used to fade out the importance of the potentially noisy landmarks towards the end of the registration process
addOptional(ip, 'maxIterN', 20, @isnumeric);
addOptional(ip, 'alphaRelaxRatio', 0.8, @isnumeric);
addOptional(ip, 'gamma', 0.1, @isnumeric); % ? can be used to weight differences in the rotational and skew part of the deformation against the translational part of the deformation
addOptional(ip, 'epsilon', 1e-4, @isnumeric);
addOptional(ip, 'is_detail', true, @islogical);
addOptional(ip, 'plot', false, @islogical);
parse(ip, varargin{:});
option = ip.Results;

% generate Laplacian matrix
[~,M] = gen_laplacian_matrix(model.mesh);
% initialize variables
vtxN = length(model.vtx);
vtxTraj = zeros(size(model.vtx));

hist_it = 1;

if option.plot
    clf;
    Source.vertices = model.vtx;
    Source.faces = model.mesh;
    Target.vertices = modelRef.vtx;
    Target.faces = modelRef.mesh;
    
    p = patch(Target, 'facecolor', 'b', 'EdgeColor',  'none', ...
              'FaceAlpha', 0.5);
    hold on;
    
    h = patch(Source, 'facecolor', 'r', 'EdgeColor',  'none', ...
        'FaceAlpha', 0.5);
    material dull; light; grid on; xlabel('x'); ylabel('y'); zlabel('z');
    view([60,30]); axis equal; axis manual;
    legend('Target', 'Source', 'Location', 'best')
    drawnow;
end

% kdtree
kdtree = KDTreeSearcher(modelRef.vtx);
% Set matrix G (equation (3) in Amberg et al.) 
G = diag([1 1 1 option.gamma]);
% Precompute kronecker product of M and G
kron_M_G = kron(M, G);
W = speye(vtxN);
kron_vtxN_ones = kron([1:vtxN]',ones(4,1));
vtxN_list = [1:vtxN*4]';
spalloc_M = spalloc(size(M,1)*4,3,0);

tic;
% optimize over x
for it = 1:option.maxIterN   
    while true
        % find correspondence: closest points
        %kdtree = KDTreeSearcher(modelRef.vtx);
        [U,~] = surf_projection(model, modelRef, kdtree);
        projDist = sum(sqrt(sum((model.vtx - U).^2,2)));
        % enforce landmark correspondences
        U(model.anchor,:) = modelRef.vtx(modelRef.anchor,:);
        % compute optimal displacement vector
%         G = speye(4);
%         G(end, end) = option.gamma;
        %W = speye(vtxN);
        Ddata = [model.vtx, ones(vtxN,1)]';
        %D = sparse(kron([1:vtxN]',ones(4,1)), [1:vtxN*4]', Ddata(:));
        D = sparse(kron_vtxN_ones, vtxN_list, Ddata(:));
        DL = D(model.anchor,:);
        UL = U(model.anchor,:);
        %A = [option.alpha*kron(M,G); W*D; option.beta*DL];
        A = [option.alpha*kron_M_G; W*D; option.beta*DL];
        %B = [spalloc(size(M,1)*4,3,0); W*U; option.beta*UL];
        B = [spalloc_M; W*U; option.beta*UL];
        %Xaff=(A'*A)\(A'*B);
        Xaff = A\B;
        % update
        model.vtx = full(D*Xaff);
        updateDist = sum(sqrt(sum((model.vtx - vtxTraj).^2,2)))/vtxN;
        vtxTraj = model.vtx;
        %updateDist = normest(Xaff - prvXaff)/vtxN;
        if option.is_detail
            fprintf('it= %d,  alpha=%f, projDist=%f, updateDist=%f, time=%fsec\n',...
                it,option.alpha,projDist,updateDist,toc);
        else
            fprintf('.');
        end
        
        hist_vtx{hist_it,1} = model.vtx;
        hist_alpha{hist_it} = option.alpha;
        
        hist_it = hist_it + 1;
        
        % update plot
        if option.plot
            set(h, 'Vertices', full(model.vtx));
            drawnow;
        end
        
        if updateDist < option.epsilon
            break;
        end
    end
    
    hist_vtx_stiff{it,1} = model.vtx;
    hist_alpha_stiff{it} = option.alpha;
           
    option.alpha=option.alpha*option.alphaRelaxRatio;
end
model.hist_vtx = hist_vtx;
model.hist_alpha = hist_alpha;

model.hist_vtx_stiff = hist_vtx_stiff;
model.hist_alpha_stiff = hist_alpha_stiff;

warning on;

% update plot and remove target mesh
if option.plot
    set(h, 'Vertices', model.vtx);
    drawnow;
    pause(2);
end
