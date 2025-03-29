clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));
addpath('../mesh_init')

for t = [0.4, 1.0]
    xleft = -pi;
    xright = pi;
    nx = 100;
    [x, dx] = mesh_init_1d(xleft, xright, nx);

    alpha = 1;
    beta = 2;
    u_exact = burgers_sin_exact(x, t, alpha, beta);

    figure;
    hold on

    if t > 1 / abs(beta)
        x_star = -pi + alpha * t;
        line([x_star, x_star], [min(u_exact), max(u_exact)], 'Color', 'r', 'LineStyle', '--');
    end

    plot(x, u_exact)
    hold off
end

xleft = 0;
xright = 2 * pi;
nx = 200;

figure;
hold on

for t = [0, 0.4, 2.0, 3.0]
    [x, dx] = mesh_init_1d(xleft, xright, nx);

    alpha = 0;
    beta = 1;

    if t > 1 / abs(beta)
        u0 = @(s) alpha + beta * sin(s);
        plot(x + u0(x) * t, u0(x), LineStyle = '--', DisplayName = sprintf('t = %.2f (ref)', t));
    end

    u_exact = burgers_sin_exact(x, t, alpha, beta);
    plot(x, u_exact, LineWidth = 2, DisplayName = sprintf('t = %.2f', t))
end

xlim([xleft, xright])
legend();
hold off
