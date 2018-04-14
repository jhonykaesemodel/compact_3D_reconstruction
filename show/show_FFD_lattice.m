function [hLines, h_latt] = show_FFD_lattice(P, l, m, n, varargin)

ip = inputParser;
addOptional(ip, 'MarkerSize', 20);
addOptional(ip, 'MarkerEdgeColor', [133 153 0]/255);
addOptional(ip, 'ColorLine', [181 137 0]/255);
addOptional(ip, 'LineWidth', 0.5);
addOptional(ip, 'isLine', true);
parse(ip, varargin{:});
option = ip.Results;

if option.isLine
    
Psharp = reshape(P, l+1, m+1, n+1, 3);

it = 1;

for i = 1:l+1
    for j = 1:m+1
        for k = 1:n     
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i,j,k+1,1), Psharp(i,j,k+1,2), Psharp(i,j,k+1,3)];
            p = [p1; p2];
            hLine = line(p(:,1), p(:,2), p(:,3));
            hLines{it} = hLine;
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
            set(hLine, 'Color', option.ColorLine, 'LineWidth', option.LineWidth)
        end
    end
end

for i = 1:l+1
    for j = 1:m
        for k = 1:n+1
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i,j+1,k,1), Psharp(i,j+1,k,2), Psharp(i,j+1,k,3)];
            p = [p1; p2];
            hLine = line(p(:,1), p(:,2), p(:,3));
            hLines{it} = hLine;
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
            set(hLine, 'Color', option.ColorLine, 'LineWidth', option.LineWidth)
        end
    end
end

for i = 1:l
    for j = 1:m+1
        for k = 1:n+1
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i+1,j,k,1), Psharp(i+1,j,k,2), Psharp(i+1,j,k,3)];
            p = [p1; p2];
            hLine = line(p(:,1), p(:,2), p(:,3));
            hLines{it} = hLine;
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
            set(hLine, 'Color', option.ColorLine, 'LineWidth', option.LineWidth)
        end
    end
end

end

hold on
h_latt = plot3(P(:,1),P(:,2),P(:,3), 'b.', 'MarkerSize', option.MarkerSize, ...
    'MarkerEdgeColor', option.MarkerEdgeColor);
