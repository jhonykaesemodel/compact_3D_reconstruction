function mesh_info = get_mesh_info(dataCAD)
%% this function gets mesh information

if ~isfield(dataCAD, 'vertices')
    [dataCAD.vertices] = dataCAD.vtx;
    dataCAD = rmfield(dataCAD,'vtx');
    [dataCAD.faces] = dataCAD.mesh;
    dataCAD = rmfield(dataCAD,'mesh');
end

% get number of vertices
num_vert = size(dataCAD.vertices,1);
% get min
minXYZ.x = min(dataCAD.vertices(:,1));
minXYZ.y = min(dataCAD.vertices(:,2));
minXYZ.z = min(dataCAD.vertices(:,3));
% get max
maxXYZ.x = max(dataCAD.vertices(:,1));
maxXYZ.y = max(dataCAD.vertices(:,2));
maxXYZ.z = max(dataCAD.vertices(:,3));

% get struct
mesh_info.vertices = dataCAD.vertices;
mesh_info.faces = dataCAD.faces;
mesh_info.minXYZ = minXYZ;
mesh_info.maxXYZ = maxXYZ;
mesh_info.numVert = num_vert;
