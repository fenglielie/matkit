function errors = dg_errors(uh, u, x, dx, pk, gk, basis)
    % errors(1, :): L1
    % errors(2, :): L2
    % errors(3, :): Linf

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    y = M * uh;
    y_exact = u(x + dx/2 * points);
    % x is a row vector, points is a column vector

    diff = y - y_exact;
    error_inf = max(abs(diff(:)));

    diff1 = dx/2 * W * diff;
    error_l1 = sum(abs(diff1(:)));

    diff2 = dx/2 * W * (diff .^2);
    error_l2 = sqrt(sum(diff2(:)));

    errors = [error_l1; error_l2; error_inf];
end
