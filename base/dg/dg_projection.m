function u = dg_projection(f, x, dx, pk, gk, basis)

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    nx = size(x, 2);
    z = zeros(gk, nx);

    for idx = 1:nx
        y = x(idx) + dx/2 * points;
        z(:, idx) = f(y);
    end

    u = (M' * W * M) \ (M' * W * z);
end
