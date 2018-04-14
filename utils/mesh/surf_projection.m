% Compute the projection of each point in Xsrc onto the surface of Xref
% function [XsrcProj,closestIdxSrc]=surf_projection(...
%     Xsrc,Xref,XmeshRef,kdtree,modelRef.triNormal,triInvRef,pointTriConnRef)
function [vtxProj, closestIdxAll] = surf_projection(model, modelRef, kdtree)

vtxAll = model.vtx;
vtxN = size(vtxAll,1);
vtxProj = zeros(vtxN,3);
closestIdxAll = knnsearch(kdtree,vtxAll);

%parfor i = 1:vtxN
for i = 1:vtxN
    vtxProj(i,:) = surf_projection_parfor(vtxAll(i,:),closestIdxAll(i),modelRef);
end

function vtxProj = surf_projection_parfor(vtx,closestIdx,modelRef)

% 1. find closest triangle
% get candidate triangles around the closest vertex
candTriLabels = modelRef.conn{closestIdx};
candTriN = length(candTriLabels);
isOnTri = false(candTriN,1);
% compute the projection of vtx onto each triangle
candTriNormal = modelRef.triNormal(candTriLabels,:);
candTriInv = modelRef.triInv(candTriLabels);
tLine = -candTriNormal(:,4)-candTriNormal(:,1:3)*vtx';
vtxCandProj = bsxfun(@plus,vtx,bsxfun(@times,tLine,candTriNormal(:,1:3)));
% check if the projection lies inside each triangle
for c = 1:candTriN
    alpha = candTriInv{c}*vtxCandProj(c,:)';
    isOnTri(c) = (sum(alpha>=0)==3);
end
if(sum(isOnTri)~=0)
    % select the triangle inside which the projection lies with the minimum distance 
    [~,onTriClosestIdx] = min(abs(modelRef.triNormal(isOnTri,4)));
    vtxProj = vtxCandProj(onTriClosestIdx,:);
else
    % 2. find closest edge
    % get candidate edges connected to the closest vertex
    candEdgeEndIdx = unique(modelRef.mesh(candTriLabels,:));
    candEdgeEndIdx(candEdgeEndIdx==closestIdx)=[];
    candEdgeVec = bsxfun(@minus,modelRef.vtx(candEdgeEndIdx,:),modelRef.vtx(closestIdx,:));
    % check if the projection lies on each edge
    vtxVec = vtx-modelRef.vtx(closestIdx,:);
    tLine2 = candEdgeVec*vtxVec'./sum(candEdgeVec.^2,2);
    isOnLine = ((0<=tLine2)&(tLine2<=1));
    if(sum(isOnLine)~=0)
        % select the edge on which the projection lies with the minimum distance
        onLineEdgeLabel = find(isOnLine);
        dist2 = sqrt(sum(bsxfun(@minus,bsxfun(@times,candEdgeVec(onLineEdgeLabel,:),tLine2(onLineEdgeLabel)),vtxVec).^2,2));
        [~,onLineClosestLabel2] = min(dist2);
        onLineClosestLabel = onLineEdgeLabel(onLineClosestLabel2);
        vtxProj = candEdgeVec(onLineClosestLabel,:)*tLine2(onLineClosestLabel)+modelRef.vtx(closestIdx,:);
    else
        % 3. directly map to closest vertex
        vtxProj = modelRef.vtx(closestIdx,:);
    end
end
