function bernstein = bernstein_poly(n, v, stu)

% the n + 1 Bernstein basis polynomials of degree n are defined as
binom_coeff = nchoosek(n, v);
bernstein = binom_coeff * (1-stu)^(n-v) * stu^v;
