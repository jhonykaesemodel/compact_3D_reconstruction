function vert_deformed = deform_mesh(mesh_info, ffd_coord, lattice, l, m, n)

vertices = mesh_info.vertices;
vert_deformed = zeros(mesh_info.numVert,3);

disp('Deforming model...')
tic
for i = 1:mesh_info.numVert
    % compute the deformation by the trivariate tensor product Bernstein
    % polynomial function
    vertex_deformed = trivariate_bernstein(lattice, vertices(i,:), ffd_coord, l, m, n);
    vert_deformed(i,1) = vertex_deformed.x;
    vert_deformed(i,2) = vertex_deformed.y;
    vert_deformed(i,3) = vertex_deformed.z;
    %fprintf('Vertex (new): %f, %f, %f \n', vertDeformed(i,1), vertDeformed(i,2), vertDeformed(i,3))
end
t = toc;
fprintf('Done in %.2f s!\n', t)
