function u = dg_projection_eqs(f, x, dx, pk, gk, basis, dim)

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    Md = kron(eye(dim), M);
    Wd = kron(eye(dim), W);

    nx = size(x,2);
    z = zeros(dim*gk,nx);

    v_cs = cell(dim,1);
    for idx = 1:nx
        y = x(idx) + dx/2 * points; % column vector
        [v_cs{:}] = f(y);
        z(:,idx) = cell2mat(v_cs);
    end

    u = (Md' * Wd * Md) \ (Md' * Wd * z);
end
