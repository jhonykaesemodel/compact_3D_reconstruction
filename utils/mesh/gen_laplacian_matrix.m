% Generate Lapacian matrix and incidence matrix
function [L, M] = gen_laplacian_matrix(Xmesh)

XN = max(Xmesh(:));
Xmesh2 = [Xmesh,Xmesh];
Xmesh3 = [Xmesh2(:,1:2);Xmesh2(:,3:4);Xmesh2(:,5:6)];
Xmesh3 = sort(Xmesh3,2,'ascend');
Xmesh3label = (Xmesh3(:,1)-1)*XN+Xmesh3(:,2);
[~,uniqueIdx,~] = unique(Xmesh3label);
edgeVertexIdx = Xmesh3(uniqueIdx,:);
edgeN = size(edgeVertexIdx,1);
edgeLabels = [1:edgeN]';
M = sparse([edgeLabels;edgeLabels],[edgeVertexIdx(:,1);edgeVertexIdx(:,2)],[ones(edgeN,1);-ones(edgeN,1)],edgeN,XN);
L = M'*M;
