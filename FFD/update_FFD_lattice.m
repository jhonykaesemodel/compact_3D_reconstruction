function update_FFD_lattice(P, l, m, n, hLines, h_latt)

Psharp = reshape(P, l+1, m+1, n+1, 3);

it = 1;

for i = 1:l+1
    for j = 1:m+1
        for k = 1:n     
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i,j,k+1,1), Psharp(i,j,k+1,2), Psharp(i,j,k+1,3)];
            p = [p1; p2];
            hLine = hLines{it};
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
        end
    end
end

for i = 1:l+1
    for j = 1:m
        for k = 1:n+1
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i,j+1,k,1), Psharp(i,j+1,k,2), Psharp(i,j+1,k,3)];
            p = [p1; p2];
            hLine = hLines{it};
            hLines{it} = hLine;
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
        end
    end
end

for i = 1:l
    for j = 1:m+1
        for k = 1:n+1
            p1 = [Psharp(i,j,k,1), Psharp(i,j,k,2), Psharp(i,j,k,3)];
            p2 = [Psharp(i+1,j,k,1), Psharp(i+1,j,k,2), Psharp(i+1,j,k,3)];
            p = [p1; p2];
            hLine = hLines{it};
            hLines{it} = hLine;
            it = it + 1;
            set(hLine,'XData', p(:,1), 'YData', p(:,2), 'ZData', p(:,3));
        end
    end
end

x = P(:,1);
y = P(:,2);
z = P(:,3);
set(h_latt,'XData',x,'YData',y,'ZData', z);
