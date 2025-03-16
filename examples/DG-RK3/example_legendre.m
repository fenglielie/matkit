clc;
clear;
close all;

cd(fileparts(mfilename('fullpath')));
addpath('../../base/gauss_quadrature')
addpath('../../base/burgers_sin_exact')
addpath('../../base/weno')
addpath('../../base/dg')
addpath('../../base/dg/core')
addpath('../../utils/common')

alpha = 0.5;
beta = 1;
xleft = -pi;
xright = pi;

pk = 2; % Pk
gk = 5; % Gauss Points

%% order test

t1 = 0.5;
nxlist = [10,20,40,80,160,320,640];
n = length(nxlist);
error = zeros(3,n);

for w = 1:n
    [x,dx] = mesh_init_1d(xleft,xright,nxlist(w));

    init_func = @(s) alpha + beta * sin(s);
    uh0 = dg_projection(init_func, x, dx, pk, gk, MatLegendre(pk+1));
    uh = dg_rk3_scheme(uh0, dx, t1, @burgers_f, @burgers_fhat_LF, @burgers_df, pk, gk, MatLegendre(pk+1), MatLegendreDx(pk+1));

    u_exact_func = @(s) burgers_sin_exact(s,t1,alpha,beta);

    error(:,w) = dg_errors(uh,u_exact_func, x, dx, pk, gk, MatLegendre(pk+1));
end

show_results(nxlist,error(1,:),error(2,:),error(3,:));

%% plot test

t2 = 1.5;
nxlist2 = [20,80];

nx_ref = 320;
[x_ref,dx_ref] = mesh_init_1d(xleft,xright,nx_ref);

exact_ref_func = @(s) burgers_sin_exact(s,t2,alpha,beta);
u_exact_ref = dg_projection(exact_ref_func, x_ref, dx_ref, pk, gk, MatLegendre(pk+1));

figure;
hold on

for w=1:2
    [x,dx] = mesh_init_1d(xleft,xright,nxlist2(w));

    init_func = @(s) alpha + beta * sin(s);
    uh0 = dg_projection(init_func, x, dx, pk, gk, MatLegendre(pk+1));
    uh = dg_rk3_scheme(uh0, dx, t2, @burgers_f, @burgers_fhat_LF, @burgers_df, pk, gk, MatLegendre(pk+1), MatLegendreDx(pk+1));

    v = MatLegendre(pk+1).eval(0,pk+1); % column vector

    plot(x_ref, v' * u_exact_ref)
    plot(x, v' * uh)
end

hold off

function result = burgers_fhat_LF(ul, ur, c)
    result = 0.25*(ul.^2 + ur.^2) - (0.5*c).*(ur-ul);
end

function result = burgers_df(u)
    result = u;
end

function result = burgers_f(u)
    result = 0.5*u.^2;
end
