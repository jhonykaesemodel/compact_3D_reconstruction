function [h, h_anch, hLines, h_latt] = show_model(model, varargin)    

if ~isfield(model, 'vertices')
    [model.vertices] = model.vtx;
    model = rmfield(model,'vtx');
    [model.faces] = model.mesh;
    model = rmfield(model,'mesh');
end

ip = inputParser;
addOptional(ip, 'EdgeColor', 'none');
addOptional(ip, 'FaceColor', 'b');
addOptional(ip, 'AnchorColor', 'r');
addOptional(ip, 'AnchorMarker', '.');
addOptional(ip, 'MarkerSize', 10);
addOptional(ip, 'FaceAlpha', 1);
addOptional(ip, 'projection', []);
addOptional(ip, 'axisLimit', []);
addOptional(ip, 'EdgeAlpha', 1);
addOptional(ip, 'ColorMap', []);
addOptional(ip, 'rotation', []);
addOptional(ip, 'AnchorNum', false);
addOptional(ip, 'lighting', true);
addOptional(ip, 'isAnchor', true);
addOptional(ip, 'isAxisLabel', true);
addOptional(ip, 'isLattice', false);
addOptional(ip, 'ColorGCA', []);
addOptional(ip, 'showModel', true);
addOptional(ip, 'isMesh', false);
addOptional(ip, 'isPoints', false);
addOptional(ip, 'isAxis', true);

parse(ip, varargin{:});
option = ip.Results;

if option.isMesh
    option.FaceColor = 'none';
    option.lighting = false;
    option.ColorGCA = [];
end

if ~isempty(option.projection)
    if size(option.projection.rotation, 1) == 2
        rotation = zeros(3);
        rotation(1:2, :) = option.projection.rotation;
        rotation(3, :) = cross(rotation(1, :), rotation(2, :));
        if det(rotation) < 0
            rotation(3, :) = -rotation(3, :);
        end
    else
        rotation = option.projection.rotation;
    end
    model.vertices = model.vertices*rotation';
end

if ~isempty(option.rotation)
    model.vertices = model.vertices*option.rotation';
end

if option.showModel
    if option.isPoints
         h = plot3(model.vertices(:, 1), model.vertices(:, 2), model.vertices(:, 3), ...
            'LineStyle', 'none', ...
            'color', option.AnchorColor, ...
            'marker', option.AnchorMarker,...
            'MarkerSize', option.MarkerSize);
        grid on
        if ~option.isAxis
            axis off;
        end
    else
        if isempty(option.ColorMap)
            h = trimesh(model.faces, model.vertices(:, 1), model.vertices(:, 2), model.vertices(:, 3));
            h.EdgeColor = option.EdgeColor;
            h.FaceColor = option.FaceColor;
            if ~option.isAxis
                axis off;
            end
        else
            h = trisurf(model.faces, model.vertices(:, 1), model.vertices(:, 2), ...
                model.vertices(:, 3), option.ColorMap);
            colormap(winter);
            %h.EdgeColor = 'none';
            option.EdgeAlpha = 0.5;
            if ~option.isAxis
                axis off;
            end
        end
        h.EdgeAlpha = option.EdgeAlpha;
        h.FaceAlpha = option.FaceAlpha;
    end
    
    if option.isAxisLabel
        xlabel('x')
        ylabel('y')
        zlabel('z')
    end
    axis equal
    if ~isempty(option.axisLimit)
        axis(option.axisLimit);
    end
end

if option.isAnchor
    hold on
    h_anch = plot3(model.vertices(model.anchor(model.anchor~=0), 1),...
        model.vertices(model.anchor(model.anchor~=0), 2), ...
        model.vertices(model.anchor(model.anchor~=0), 3),...
        'LineStyle', 'none', ...
        'color', option.AnchorColor, ...
        'marker', option.AnchorMarker,...
        'MarkerSize', option.MarkerSize);
end
%title(model.model_info.uid);

if option.AnchorNum
    for i = 1:numel(model.anchor)
        if model.anchor(i) == 0
            continue;
        end
        txt = num2str(i);
        text(model.vertices(model.anchor(i), 1), ...
             model.vertices(model.anchor(i), 2), ...
             model.vertices(model.anchor(i), 3), ...
             txt, 'FontSize', 20, 'Color', 'r');
    end
end

if ~isempty(option.projection) || ~isempty(option.rotation)
    view(2);
end

if option.lighting
    light('Position', [-1,-1,1], 'Style', 'infinite');
    light('Position', [1,1,-1], 'Style', 'infinite');
    light('Position', [1,-1,-1], 'Style', 'infinite');
    lighting flat %phong
end

if ~isempty(option.ColorGCA)
    set(gca,'Color', option.ColorGCA);
end

if option.isLattice
    markerSize = 10;
    lineWidth = 0.1;
    if ~isfield(model, 'Phat')
        model.Phat = model.P;
    end
    [hLines, h_latt] = show_FFD_lattice(model.Phat, model.l, model.m, model.n,  'MarkerSize', ...
        markerSize, 'LineWidth', lineWidth);
else
    hLines = [];
    h_latt =[];
end

drawnow;
