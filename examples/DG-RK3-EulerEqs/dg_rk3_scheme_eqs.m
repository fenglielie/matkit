function u = dg_rk3_scheme_eqs(u, dx, tend, f, fhat, get_alpha, pk, gk, basis, basis_dx, is_riemann)

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1); % size = [gk,pk+1]
    W = diag(weights); % size = [gk,gk]
    InvMass = inv(dx/2 * M' * W * M); % size = [pk+1,pk+1]
    DM = 2/dx * basis_dx.eval(points, pk+1); % size = [gk,pk+1]

    vl = basis.eval(-1, pk+1); % column vector size = [pk+1,1]
    vc = basis.eval(0, pk+1);
    vr = basis.eval(1, pk+1);

    params = struct();
    params.vl = vl;
    params.vc = vc;
    params.vr = vr;

    params.M3 = kron(eye(3), M); % size = [3*gk,3*(pk+1)]
    params.W3 = kron(eye(3), W); % size = [3*gk,3*gk]
    params.InvMass3 = kron(eye(3), InvMass); % size = [3*(pk+1),3*(pk+1)]
    params.DM3 = kron(eye(3), DM); % size = [3*gk,3*(pk+1)]
    params.vl3 = kron(eye(3), vl); % size = [3*(pk+1),3]
    params.vc3 = kron(eye(3), vc);
    params.vr3 = kron(eye(3), vr);

    params.is_riemann = is_riemann;

    tnow = 0;
    while tnow < tend - 1e-10
        uh_mid = params.vc3'*u; % size(u) = [3*(pk+1),n], size(uh_mid) = [3,n]
        alpha = get_alpha(uh_mid);
        global_alpha = max(alpha);

        dt = 1/((2*pk+3)*global_alpha)*dx^((pk+1)/3);
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u, dx, f, fhat, get_alpha, params);
        u2 = 3/4 * u + 1/4 * (u1 + dt * L_op(u1, dx, f, fhat, get_alpha, params));
        u3 = 1/3 * u + 2/3 * (u2 + dt * L_op(u2, dx, f, fhat, get_alpha, params));
        u = u3;

        tnow = tnow + dt;
    end

end


function result = L_op(u, dx, f, fhat, get_alpha, params)
    % size(u) = [3*(pk+1),n]

    ul = params.vl3' * u; % size = [3,n]
    ur = params.vr3' * u;

    alpha_l = get_alpha(ul); % size = [1,n]
    alpha_r = get_alpha(ur);

    lf_alpha = max([circshift(alpha_r, 1); alpha_l]); % size = [1,n]
    rf_alpha = max([alpha_r; circshift(alpha_l, -1)]);

    fhat_l = fhat(circshift(ur, 1, 2), ul, lf_alpha); % size = [3,n]
    fhat_r = fhat(ur, circshift(ul, -1, 2), rf_alpha);

    q3 = params.M3 * u; % size = [3*gk,n]
    main = dx/2 * (params.DM3') * params.W3 * f(q3); % size = [3*(pk+1),n]

    % size(vl) = [pk+1,1]
    % size = [3*(pk+1),n]
    left_boundary = [params.vl .* fhat_l(1,:);
        params.vl .* fhat_l(2,:);
        params.vl .* fhat_l(3,:)];
    right_boundary = [params.vr .* fhat_r(1,:);
        params.vr .* fhat_r(2,:);
        params.vr .* fhat_r(3,:)];

    result = params.InvMass3 * (main - right_boundary + left_boundary); % size = [3*(pk+1),n]

    % Riemann boundary condition
    if params.is_riemann
        result(:,1) = 0;
        result(:,end) = 0;
    end
end
