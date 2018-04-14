function phi = symmetric_matrix(P, l, m, n, isYsym)

if nargin < 5
    isYsym = false;
end

phi = zeros(size(P,1)*3,size(P,1)*3);  

isYsym = false;

%% if X symmetry - Layers (4x4) in the X direction
idxLayerX1 = [1;5;9;13; 17;21;25;29; 33;37;41;45; 49;53;57;61];
idxLayerX2 = idxLayerX1 + 1;
idxLayerX3 = idxLayerX2 + 1;
idxLayerX4 = idxLayerX3 + 1;
idxLayers_X1_X2 = [idxLayerX1; idxLayerX2];
idxLayers_X3_X4 = [idxLayerX3; idxLayerX4];

%% if Y symmetry - Layers (4x4) in the Y direction
idxLayerY1 = [1;2;3;4; 17;18;19;20; 33;34;35;36; 49;50;51;52];
idxLayerY2 = idxLayerY1 + 4;
idxLayerY3 = idxLayerY2 + 4;
idxLayerY4 = idxLayerY3 + 4;
idxLayers_Y1_Y2 = [idxLayerY1; idxLayerY2];
idxLayers_Y3_Y4 = [idxLayerY3; idxLayerY4];

%% if Z symmetry - Layers (4x4) in the Z direction
% idxLayerZ1 = [1:16]';
% idxLayerZ2 = idxLayerZ1 + 16;
% idxLayerZ3 = idxLayerZ2 + 16;
% idxLayerZ4 = idxLayerZ3 + 16;
% idxLayers_Z1_Z2 = [idxLayerZ1; idxLayerZ2];
% idxLayers_Z3_Z4 = [idxLayerZ3; idxLayerZ4];


%% X symmetry
Paux = zeros(size(P));
Paux(idxLayers_X1_X2,1) = 1;
Paux(idxLayers_X3_X4,1) = -1;
% vec to take linear indices
vecP = vec(Paux');
subX12 = find(vecP == 1);
subX34 = find(vecP == -1);
% swap every 2 rows
subX34_aux1 = subX34(1:2:end, :);
subX34_aux2 = subX34(2:2:end, :);
subX34(1:2:end,:) = subX34_aux2;
subX34(2:2:end,:) = subX34_aux1;
% take linear indices of the symmetry matrix
indicesX1 = sub2ind(size(phi), subX12, subX12);
indicesX2 = sub2ind(size(phi), subX34, subX12);
% impose symmetry
phi(indicesX1) = 1;
phi(indicesX2) = -1;


%% Y symmetry
if isYsym % uses Y layers for symmetry
    Paux = zeros(size(P));
    Paux(idxLayers_Y1_Y2,2) = 1;
    Paux(idxLayers_Y3_Y4,2) = -1;
    % vec to take linear indices
    vecP = vec(Paux');
    subY12 = find(vecP == 1);
    subY34 = find(vecP == -1); 
    % swap every 2 rows
    subY34_aux1 = subY34(1:2:end, :);
    subY34_aux2 = subY34(2:2:end, :);
    subY34(1:2:end,:) = subY34_aux2;
    subY34(2:2:end,:) = subY34_aux1;
    % take linear indices of the symmetry matrix
    indicesY1 = sub2ind(size(phi), subY12, subY12);
    indicesY2 = sub2ind(size(phi), subY34, subY12);
    % impose symmetry
    phi(indicesY1) = 1;
    phi(indicesY2) = -1;
else % uses X layers for symmetry
    Paux = zeros(size(P));
    Paux(idxLayers_X1_X2,2) = 1;
    Paux(idxLayers_X3_X4,2) = -1;
    % vec to take linear indices
    vecP = vec(Paux');
    subY12 = find(vecP == 1);
    subY34 = find(vecP == -1);
    % swap every 2 rows
    subY34_aux1 = subY34(1:2:end, :);
    subY34_aux2 = subY34(2:2:end, :);
    subY34(1:2:end,:) = subY34_aux2;
    subY34(2:2:end,:) = subY34_aux1;
    % take linear indices of the symmetry matrix
    indicesY1 = sub2ind(size(phi), subY12, subY12);
    indicesY2 = sub2ind(size(phi), subY34, subY12);
    % impose symmetry
    phi(indicesY1) = 1;
    phi(indicesY2) = 1;
end


%% Z symmetry
% get indices from P vectorized for Z symmetry with respect to X
Paux = zeros(size(P));
Paux(idxLayers_X1_X2,3) = 1;
Paux(idxLayers_X3_X4,3) = -1;
% vec to take linear indices
vecP = vec(Paux');
subZ12 = find(vecP == 1);
subZ34 = find(vecP == -1);
% swap every 2 rows
subZ34_aux1 = subZ34(1:2:end, :);
subZ34_aux2 = subZ34(2:2:end, :);
subZ34(1:2:end,:) = subZ34_aux2;
subZ34(2:2:end,:) = subZ34_aux1;
% take linear indices of the symmetry matrix
indicesZ1 = sub2ind(size(phi), subZ12, subZ12);
indicesZ2 = sub2ind(size(phi), subZ34, subZ12);
% impose symmetry
phi(indicesZ1) = 1;
phi(indicesZ2) = 1;


%% plot matrix
%figure, imagesc(phi)
