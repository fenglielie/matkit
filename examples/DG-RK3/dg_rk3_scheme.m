function u = dg_rk3_scheme(u, dx, tend, f, fhat, df, pk, gk, basis, basis_dx)

    assert(2*gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk+1);
    W = diag(weights);
    InvMass = inv(dx/2 * M' * W * M);
    DM = 2/dx * basis_dx.eval(points, pk+1);

    vl = basis.eval(-1, pk+1); % column vector
    vc = basis.eval(0, pk+1);
    vr = basis.eval(1, pk+1);

    params = struct();
    params.M = M;
    params.W = W;
    params.InvMass = InvMass;
    params.DM = DM;
    params.vl = vl;
    params.vc = vc;
    params.vr = vr;

    tnow = 0;
    while tnow < tend - 1e-10
        uh_mid = vc'*u;
        dt = 1/((2*pk+1)*max(abs(df(uh_mid))))*dx^((pk+1)/3);
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u,dx,f,fhat,df,params);
        u2 = 3/4 * u + 1/4 * (u1 + dt * L_op(u1,dx,f,fhat,df,params));
        u3 = 1/3 * u + 2/3 * (u2 + dt * L_op(u2,dx,f,fhat,df,params));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u,dx,f,fhat,df,params)

    ul = params.vl' * u; % row vector
    ur = params.vr' * u;

    lf_alpha = max([circshift(abs(df(ur)), 1); abs(df(ul))]);
    rf_alpha = max([abs(df(ur)); circshift(abs(df(ul)), -1)]);

    fhat_l = fhat(circshift(ur, 1), ul, lf_alpha);
    fhat_r = fhat(ur, circshift(ul, -1), rf_alpha);

    main = dx/2 * (params.DM') * params.W * f(params.M * u);
    left_boundary = params.vl * fhat_l;
    right_boundary = params.vr * fhat_r;

    result = params.InvMass * (main - right_boundary + left_boundary);
end
