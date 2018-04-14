function R = align_models(model, modelRef)
% align model to the reference model

if ~isfield(modelRef, 'vtx')
    [modelRef.vtx] = modelRef.vertices;
    modelRef = rmfield(modelRef,'vertices');
    [modelRef.mesh] = modelRef.faces;
    modelRef = rmfield(modelRef,'faces');
end

assert(~isempty(model.anchor));
assert(~isempty(modelRef.anchor));

mask = ((model.anchor ~= 0) & (modelRef.anchor~=0));
anchorVtx=model.vtx(model.anchor(mask),:);
anchorRefVtx=modelRef.vtx(modelRef.anchor(mask),:);

[U, S, V] = svd(anchorVtx'*anchorRefVtx);
R=V*U';
if det(R) < 0
    V(:, 3) = -V(:, 3);
end
R=V*U';
R = round(R);
