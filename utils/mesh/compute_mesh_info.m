% Computes the triangle normals and connectivities for each vertex in the dense mesh
function model = compute_mesh_info(model)

vtxN=size(model.vtx,1);
triN=size(model.mesh,1);
conn=cell(vtxN,1);

% extract point-triangle connectivity
for t=1:triN
    conn{model.mesh(t,1)}=[conn{model.mesh(t,1)};t];
    conn{model.mesh(t,2)}=[conn{model.mesh(t,2)};t];
    conn{model.mesh(t,3)}=[conn{model.mesh(t,3)};t];
end

triNormal=zeros(triN,4);
triNormal(:,4)=-1;
triInv=cell(triN,1);

% pre-compute triangle normal
for t=1:triN
    triNormal(t,1:3)=(model.vtx(model.mesh(t,:),:)\ones(3,1))';
    triNormal(t,:)=triNormal(t,:)/norm(triNormal(t,1:3));
    triInv{t}=inv(model.vtx(model.mesh(t,:),:)');
end

model.conn=conn;
model.triNormal=triNormal;
model.triInv=triInv;
