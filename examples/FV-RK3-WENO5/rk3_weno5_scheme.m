function u = rk3_weno5_scheme(u, dx, tend, flux, df)
    tnow = 0;
    while tnow < tend - 1e-10
        dt = 1/(2*max(abs(df(u))))*dx^(5/3);
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u,dx,flux,df);
        u2 = 3/4*u + 1/4*(u1 + dt * L_op(u1,dx,flux,df));
        u3 = 1/3*u + 2/3*(u2 + dt * L_op(u2,dx,flux,df));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u, dx, flux, df)
    [ul_plus,ur_minus] = weno5(u);

    ul_plus_right = circshift(ul_plus, -1);
    ur_minus_left = circshift(ur_minus, 1);

    c = max(abs(df(u)));
    fhat_left = flux(ur_minus_left, ul_plus,c);
    fhat_right = flux(ur_minus, ul_plus_right,c);

    result = - (fhat_right - fhat_left) / dx;
end
