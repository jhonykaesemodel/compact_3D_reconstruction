function placelabel(pt,str)
x = pt(1);
y = pt(2);
h = line(x,y);
h.Marker = '.';
h = text(x,y,str);
h.HorizontalAlignment = 'center';
h.VerticalAlignment = 'bottom';
