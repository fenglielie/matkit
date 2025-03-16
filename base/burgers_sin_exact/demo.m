clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));
addpath('../mesh_init')

for t = [0.4,1.0]
    xleft = -pi;
    xright = pi;
    nx = 100;
    [x,dx] = mesh_init_1d(xleft,xright,nx);

    alpha = 1;
    beta = 2;
    u_exact = burgers_sin_exact(x,t,alpha,beta);

    figure;
    hold on

    if t > 1/abs(beta)
        x_star = -pi + alpha * t;
        line([x_star, x_star], [min(u_exact), max(u_exact)], 'Color', 'r', 'LineStyle', '--');
    end

    plot(x,u_exact)
    hold off
end
