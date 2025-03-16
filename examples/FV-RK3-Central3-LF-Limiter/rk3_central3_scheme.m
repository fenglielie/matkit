function u = rk3_central3_scheme(u, dx, tend, flux, df, limiter)
    tnow = 0;
    while tnow < tend - 1e-10
        dt = dx/(2*max(abs(df(u))));
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u,dx,flux,df,limiter);
        u2 = 3/4*u + 1/4*(u1 + dt * L_op(u1,dx,flux,df,limiter));
        u3 = 1/3*u + 2/3*(u2 + dt * L_op(u2,dx,flux,df,limiter));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u, dx, flux, df, limiter)
    ur = circshift(u, -1);
    ul = circshift(u, 1);

    ul_plus = (1/3 * ul) + (5/6 * u) - (1/6 * ur);
    ur_minus = (-1/6 * ul) + (5/6 * u) + (1/3 * ur);

    [ul_plus,ur_minus] = limiter(ul_plus,u,ur_minus,dx);

    ul_plus_right = circshift(ul_plus, -1);
    ur_minus_left = circshift(ur_minus, 1);

    c = max(abs(df(u)));
    fhat_left = flux(ur_minus_left, ul_plus,c);
    fhat_right = flux(ur_minus, ul_plus_right,c);

    result = - (fhat_right - fhat_left) / dx;
end
