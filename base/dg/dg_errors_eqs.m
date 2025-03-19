function errors = dg_errors_eqs(uh, u, x, dx, pk, gk, basis, dim, trans)
    % errors(1, :): L1
    % errors(2, :): L2
    % errors(3, :): Linf

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    % x: row vector, points: column vector
    v_cs = cell(1, dim);
    [v_cs{:}] = u(x + dx/2 * points); % v1: matrix
    u_cs = cell(1, dim);
    [u_cs{:}] = trans(v_cs{:});

    vh_cs = cell(1, dim);
    for ii=1:dim
        vh_cs{ii} = M * uh((ii-1)*(pk+1)+1:ii*(pk+1), :);
    end
    uh_cs = cell(1, dim);
    [uh_cs{:}] = trans(vh_cs{:});

    errors_l1 = zeros(1, dim);
    errors_l2 = zeros(1, dim);
    errors_inf = zeros(1, dim);
    for ii=1:dim
        y = uh_cs{ii};
        y_exact = u_cs{ii};

        diff = y - y_exact;
        errors_inf(ii) = max(abs(diff(:)));

        diff1 = dx/2 * W * diff;
        errors_l1(ii) = sum(abs(diff1(:)));

        diff2 = dx/2 * W * (diff .^2);
        errors_l2(ii) = sum(diff2(:));
    end

    error_inf = max(errors_inf);
    error_l1 = sum(errors_l1);
    error_l2 = sqrt(sum(errors_l2));

    errors = [error_l1; error_l2; error_inf];
end
