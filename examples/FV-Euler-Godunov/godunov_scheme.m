function u = godunov_scheme(u, dx, tend, fhat, df)
    tnow = 0;
    while tnow < tend - 1e-10
        dt = dx/(2*max(abs(df(u))));
        dt = min([dt, tend - tnow]);

        u = u + dt * L_op(u, dx, fhat);
        tnow = tnow + dt;
    end
end

function result = L_op(u, dx, fhat)
    fhat_left = fhat(circshift(u, 1), u);
    fhat_right = fhat(u, circshift(u, -1));
    result = - (fhat_right - fhat_left) / dx;
end
