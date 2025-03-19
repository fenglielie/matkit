function u = rk3_weno5_scheme(u, dx, tend, fhat, df)
    % INPUT:
    %   u         - Initial solution, must be a numeric vector or matrix.
    %   dx        - Spatial step size, must be a positive scalar.
    %   tend      - Final time, must be a positive scalar.
    %   fhat      - Numerical flux function handle, defined as fhat(u_L, u_R, c).
    %   df        - Derivative of the flux function, defined as df(u).
    %
    % OUTPUT:
    %   u         - Numerical solution at final time.

    assert(isnumeric(u) && (isvector(u) || ismatrix(u)), 'u must be a numeric vector or matrix.');
    assert(isnumeric(dx) && isscalar(dx) && dx > 0, 'dx must be a positive scalar.');
    assert(isnumeric(tend) && isscalar(tend) && tend > 0, 'tend must be a positive scalar.');
    assert(isa(fhat, 'function_handle'), 'fhat must be a function handle.');
    assert(isa(df, 'function_handle'), 'df must be a function handle.');

    tnow = 0;
    while tnow < tend - 1e-10
        dt = 1/(2*max(abs(df(u))))*dx^(5/3);
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u,dx,fhat,df);
        u2 = 3/4*u + 1/4*(u1 + dt * L_op(u1,dx,fhat,df));
        u3 = 1/3*u + 2/3*(u2 + dt * L_op(u2,dx,fhat,df));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u, dx, fhat, df)
    [ul_plus,ur_minus] = weno5(u);

    ul_plus_right = circshift(ul_plus, -1);
    ur_minus_left = circshift(ur_minus, 1);

    c = max(abs(df(u)));
    fhat_left = fhat(ur_minus_left, ul_plus,c);
    fhat_right = fhat(ur_minus, ul_plus_right,c);

    result = - (fhat_right - fhat_left) / dx;
end
