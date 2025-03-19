function u = rk3_central3_scheme(u, dx, tend, fhat, df, limiter)
    % INPUT:
    %   u         - Initial solution, must be a numeric vector or matrix.
    %   dx        - Spatial step size, must be a positive scalar.
    %   tend      - Final time, must be a positive scalar.
    %   fhat      - Numerical flux function handle, defined as fhat(u_L, u_R, c).
    %   df        - Derivative of the flux function, defined as df(u).
    %   limiter   - Limiter function handle, defined as limiter(a, b, c, h).
    %
    % OUTPUT:
    %   u         - Numerical solution at final time.

    assert(isnumeric(u) && (isvector(u) || ismatrix(u)), 'u must be a numeric vector or matrix.');
    assert(isnumeric(dx) && isscalar(dx) && dx > 0, 'dx must be a positive scalar.');
    assert(isnumeric(tend) && isscalar(tend) && tend > 0, 'tend must be a positive scalar.');
    assert(isa(fhat, 'function_handle'), 'fhat must be a function handle.');
    assert(isa(df, 'function_handle'), 'df must be a function handle.');
    assert(isa(limiter, 'function_handle'), 'limiter must be a function handle.');

    tnow = 0;
    while tnow < tend - 1e-10
        dt = dx/(2*max(abs(df(u))));
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u, dx, fhat, df, limiter);
        u2 = 3/4*u + 1/4*(u1 + dt * L_op(u1, dx, fhat, df, limiter));
        u3 = 1/3*u + 2/3*(u2 + dt * L_op(u2, dx, fhat, df, limiter));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u, dx, fhat, df, limiter)
    ur = circshift(u, -1);
    ul = circshift(u, 1);

    ul_plus = (1/3 * ul) + (5/6 * u) - (1/6 * ur);
    ur_minus = (-1/6 * ul) + (5/6 * u) + (1/3 * ur);

    [ul_plus, ur_minus] = limiter(ul_plus, u, ur_minus, dx);

    ul_plus_right = circshift(ul_plus, -1);
    ur_minus_left = circshift(ur_minus, 1);

    c = max(abs(df(u)));
    fhat_left = fhat(ur_minus_left, ul_plus, c);
    fhat_right = fhat(ur_minus, ul_plus_right, c);

    result = - (fhat_right - fhat_left) / dx;
end
