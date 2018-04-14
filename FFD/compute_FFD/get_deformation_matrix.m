function B = get_deformation_matrix(mesh_info, ffd_coord, l, m, n)

numCP = (l+1)*(m+1)*(n+1);
Xffd = mesh_info.vertices;
weight = zeros(l+1,m+1,n+1);
B = zeros(mesh_info.numVert, numCP);

disp('Computing deformation matrix...')
tic
for v = 1:mesh_info.numVert
    vert.x = Xffd(v,1);
    vert.y = Xffd(v,2);
    vert.z = Xffd(v,3);
    
    % the deformed position X_ffd of an arbitrary point X is found by first
    % computing its (s,t,u) coordinates from equation (1) - Sederberg 1986
    stuVert = convert_to_stu(vert, ffd_coord);
    
    %fprintf('Vertex (XYZ): %f, %f, %f \n', vert.x, vert.y, vert.z)
    %fprintf('Vertex (STU): %f, %f, %f \n', stuVert.s, stuVert.t, stuVert.u)
    for i = 1:l+1
        for j = 1:m+1
            for k = 1:n+1
                weight(i,j,k) = bernstein_poly(l, i-1, stuVert.s) * ...
                                bernstein_poly(m, j-1, stuVert.t) * ...
                                bernstein_poly(n, k-1, stuVert.u);
            end
        end
    end
    B(v,:) = reshape(weight, 1, numCP);
end
t = toc;
fprintf('Done in %.2f s!\n', t)
