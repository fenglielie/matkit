function u = dg_projection_eulereqs(f, x, dx, pk, gk, basis)

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    M3 = kron(eye(3), M);
    W3 = kron(eye(3), W);

    nx = size(x,2);
    z = zeros(3*gk,nx);

    for idx = 1:nx
        y = x(idx) + dx/2 * points; % column vector
        [v1,v2,v3] = f(y);
        z(:,idx) = [v1; v2; v3];
    end

    u = (M3' * W3 * M3) \ (M3' * W3 * z);
end
