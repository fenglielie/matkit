function errors = dg_errors_eulereqs(uh, f, x, dx, pk, gk, basis)
    % errors(1,:): L1
    % errors(2,:): L2
    % errors(3,:): Linf

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);

    % x: row vector, points: column vector
    [v1,v2,v3] = f(x + dx/2 * points); % v1: matrix
    [rho,~,~] = eulereqs_trans2raw(v1,v2,v3);

    vh1 = M * uh(1:pk+1,:);
    vh2 = M * uh(pk+2:2*(pk+1),:);
    vh3 = M * uh(2*(pk+1)+1:3*(pk+1),:);
    [rhoh,~,~] = eulereqs_trans2raw(vh1,vh2,vh3);

    y = rhoh;
    y_exact = rho;

    diff = y - y_exact;
    error_inf = max(abs(diff(:)));

    diff1 = dx/2 * W * diff;
    error_l1 = sum(abs(diff1(:)));

    diff2 = dx/2 * W * (diff .^2);
    error_l2 = sqrt(sum(diff2(:)));

    errors = [error_l1; error_l2; error_inf]; % TODO only rho
end
