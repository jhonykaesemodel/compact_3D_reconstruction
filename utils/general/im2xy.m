function x = im2xy(w, sizeI)
% transfer the image coordinate to Cartesian coordinate
x = w;
x(2, :) = sizeI(1) - x(2, :) + 1;

