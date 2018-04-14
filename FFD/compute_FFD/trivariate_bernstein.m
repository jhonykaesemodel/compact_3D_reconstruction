function vertexDeformed = trivariate_bernstein(lattice, vertices, ffdCoord, l, m, n)

vert.x = vertices(:,1);
vert.y = vertices(:,2);
vert.z = vertices(:,3);

% the deformed position X_ffd of an arbitrary point X is found by first
% computing its (s,t,u) coordinates from equation (1) - Sederberg 1986
stuVert = convertToSTU(vert, ffdCoord);
%fprintf('Vertex (XYZ): %f, %f, %f \n', vert.x, vert.y, vert.z)
%fprintf('Vertex (STU): %f, %f, %f \n', stuVert.s, stuVert.t, stuVert.u)

vertexDeformed.x = 0;
vertexDeformed.y = 0;
vertexDeformed.z = 0;

for i = 1:l+1
    for j = 1:m+1
        for k = 1:n+1
            weight = bernsteinPoly(l, i-1, stuVert.s) * ...
                     bernsteinPoly(m, j-1, stuVert.t) * ...
                     bernsteinPoly(n, k-1, stuVert.u);
            % vector containing the Cartesian coordinates of the displaced
            % point. P_ijk -> lattice contains the Cartesian coordinates of
            % the control points which is actually the coefficient
            vertexDeformed.x = vertexDeformed.x + weight * lattice(i,j,k).x;
            vertexDeformed.y = vertexDeformed.y + weight * lattice(i,j,k).y;
            vertexDeformed.z = vertexDeformed.z + weight * lattice(i,j,k).z;           
        end
    end
end
