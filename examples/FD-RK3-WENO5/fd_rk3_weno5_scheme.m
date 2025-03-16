function u = fd_rk3_weno5_scheme(u, dx, tend, fl, fr, df)
    tnow = 0;
    while tnow < tend - 1e-10
        dt = 1/(2*max(abs(df(u))))*dx^(5/3);
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u,dx,fl,fr,df);
        u2 = 3/4*u + 1/4*(u1 + dt * L_op(u1,dx,fl,fr,df));
        u3 = 1/3*u + 2/3*(u2 + dt * L_op(u2,dx,fl,fr,df));
        u = u3;

        tnow = tnow + dt;
    end
end


function result = L_op(u, dx, fl, fr, df)
    c = max(abs(df(u)));

    hl = fl(u,c);
    hr = fr(u,c);

    [~,hlr] = weno5(hl);
    [hrl,~] = weno5(hr);

    result = -(hlr + circshift(hrl, -1) - circshift(hlr,1) - hrl)/dx;
end
