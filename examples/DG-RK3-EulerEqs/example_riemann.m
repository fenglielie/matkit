clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));
run('../../base/setup.m')
run('../../utils/setup.m')


xleft = -2;
xright = 2;

pk = 2; % Pk
gk = 5; % Gauss Points

dim = 3;

basis = MatLegendre(pk+1);
basis_dx = MatLegendreDx(pk+1);


%% plot test

t = 0.6;
nxlist = [40,160];

% nx_ref = 320;
% [x_ref,dx_ref] = mesh_init_1d(xleft,xright,nx_ref);

% exact_ref_func = @(s) eulereqs_sin_exact(s,t2,alpha,beta,omega,phi,u0_ic,p0_ic);
% u_exact_ref = dg_projection_eulereqs(exact_ref_func, x_ref, dx_ref, pk, gk, basis);


for w=1:2
    figure;

    [x,dx] = mesh_init_1d(xleft,xright,nxlist(w));

    init_func = @(s) eulereqs_sod_init(s);
    uh0 = dg_projection_eqs(init_func, x, dx, pk, gk, basis, dim);
    uh = dg_rk3_scheme_eqs(uh0, dx, t, @eulereqs_f, @eulereqs_fhat_LF, @eulereqs_get_alpha, pk, gk, basis, basis_dx, dim, 1);

    vc = basis.eval(0,pk+1); % column vector

    v1 = vc' * uh(1:(pk+1),:);
    v2 = vc' * uh(pk+2:2*(pk+1),:);
    v3 = vc' * uh(2*(pk+1)+1:3*(pk+1),:);

    [rho_values, u_values, p_values] = eulereqs_trans2raw(v1,v2,v3);

    gamma = 1.4;
    e_values = p_values ./ (gamma - 1);
    % plot(x_ref, rho_mean_values_ref)

    [rho_values_ref, u_values_ref, p_values_ref, ~] = euler_riemann_exact( ...
        1, 0, 1, 0.125, 0, 0.1, gamma, x, 0, t);
    e_values_ref = p_values_ref ./ (gamma - 1);

    primitive = {rho_values, u_values, p_values, e_values};
    primitive_ref = {rho_values_ref, u_values_ref, p_values_ref, e_values_ref};
    names = {"Density", "Velocity", "Pressure", "Internal Energy"};

    for s = 1:4
        subplot(2, 2, s);
        hold on

        q_ref = primitive_ref{s};
        plot(x, q_ref, 'b', 'DisplayName', 'u-ref');

        q = primitive{s};
        plot(x, q, 'DisplayName', 'u');

        title(names{s});

        qmax = max(q);
        qmin = min(q);
        qdiff = qmax - qmin;
        ylim([qmin - 0.1 * qdiff, qmax + 0.1 * qdiff]);

        hold off
        legend('Location', 'best');
    end

end

function [v1,v2,v3] = eulereqs_sod_init(x)
    % 返回守恒变量形式 v = [v1,v2,v3] = [rho, rho u, E]
    % 尺寸与输入的x一致

    % [1,0,1]
    % [0.125,0,0.1]

    condition = x < 0;

    rho = zeros(size(x));
    u = zeros(size(x));
    p = zeros(size(x));

    rho(condition) = 1;
    u(condition) = 0;
    p(condition) = 1;

    rho(~condition) = 0.125;
    u(~condition) = 0;
    p(~condition) = 0.1;

    [v1,v2,v3] = eulereqs_trans2cv(rho,u,p);
end
