function data = compute_FFD(cad, l, m, n)

% get min-max coordinates
mesh_info = get_mesh_info(cad);

% init the FFD axis - STU coordinate system
ffd_obj = ClassFFD;
ffd_coord = ffd_obj.initAxes(mesh_info);

% create the grid of control points (lattice)
[lattice, ~] = ffd_obj.initControlLattice(ffd_coord, l, m, n);

% perform the FFD deformation
% get P (numCP X 3)
P = lattice(:);
P = cell2mat(struct2cell(P))';
B = get_deformation_matrix(mesh_info, ffd_coord, l, m, n);

% compute FFD
vertices = B * P;

% FFD data
data.vtx = vertices;
if isfield(cad, 'mesh')
    data.mesh = cad.mesh;
else
    data.mesh = cad.faces;
end
if isfield(cad, 'anchor')
    data.anchor = cad.anchor;
end
data.l = l;
data.m = m;
data.n = n;
data.P = P;
data.B = B;
