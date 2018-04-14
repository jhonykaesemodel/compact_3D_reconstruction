function show_cad_model(vertices, faces, color, alpha)

if nargin < 3
    color = 'b';
    alpha = 1;
end

%figure
trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3), ...
    'FaceColor',color, 'EdgeColor', 'none', 'facealpha', alpha);
light('Position',[-1,-1,1], 'Style', 'infinite');
light('Position',[-1,1,-1], 'Style', 'infinite');
light('Position',[1,-1,-1], 'Style', 'infinite');

lighting phong
axis equal
