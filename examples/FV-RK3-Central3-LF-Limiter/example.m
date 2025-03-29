clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));
run('../../base/setup.m')
run('../../utils/setup.m')

alpha = 0.5;
beta = 1;
xleft = -pi;
xright = pi;

limiters = {{tvb_limiter(-1), 'nolimiter'}, {tvb_limiter(0), 'tvd'}, {tvb_limiter(0.1), 'tvb 0.1'}, {tvb_limiter(3), 'tvb 3'}};

for cnt = 1:numel(limiters)
    lmt = limiters{cnt}{1};
    lmt_name = limiters{cnt}{2};

    fprintf('Test with limiter: %s\n', lmt_name);

    %% order test

    t1 = 0.5;
    nxlist = [10, 20, 40, 80, 160, 320, 640];
    n = numel(nxlist);
    errors = zeros(3, n);

    for w = 1:n
        [x, dx] = mesh_init_1d(xleft, xright, nxlist(w));

        init_func = @(s) alpha + beta * sin(s);
        uh0 = Quad().integrate(init_func, x - dx / 2, x + dx / 2) / dx;
        uh = rk3_central3_scheme(uh0, dx, t1, @burgers_fhat_LF, @burgers_df, lmt);

        exact_func = @(s) burgers_sin_exact(s, t1, alpha, beta);
        u_exact = Quad().integrate(exact_func, x - dx / 2, x + dx / 2) / dx;

        errors(1, w) = sum(abs(uh - u_exact)) * dx;
        errors(2, w) = sqrt(sum(abs(uh - u_exact) .^ 2) * dx);
        errors(3, w) = max(abs(uh - u_exact));
    end

    show_results(nxlist, errors(1, :), errors(2, :), errors(3, :));

    %% plot test

    t2 = 1.5;
    nxlist2 = [20, 80];
    nx_ref = 320;
    [x_ref, dx_ref] = mesh_init_1d(xleft, xright, nx_ref);

    exact_func = @(s) burgers_sin_exact(s, t2, alpha, beta);
    u_exact_ref = Quad().integrate(exact_func, x_ref - dx_ref / 2, x_ref + dx_ref / 2) / dx_ref;

    figure;
    hold on
    plot(x_ref, u_exact_ref)

    for w = 1:2
        [x, dx] = mesh_init_1d(xleft, xright, nxlist2(w));

        init_func = @(s) alpha + beta * sin(s);
        uh0 = Quad().integrate(init_func, x - dx / 2, x + dx / 2) / dx;
        uh = rk3_central3_scheme(uh0, dx, t2, @burgers_fhat_LF, @burgers_df, lmt);

        plot(x, uh)
    end

    hold off
end

function result = burgers_fhat_LF(ul, ur, c)
    result = 0.25 * (ul .^ 2 + ur .^ 2) - (0.5 * c) .* (ur - ul);
end

function result = burgers_df(u)
    result = u;
end
