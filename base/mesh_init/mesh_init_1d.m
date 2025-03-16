function [x,dx] = mesh_init_1d(xleft,xright,n)
    % x_{1/2} = xleft, x_{n+1/2} = xright
    % x(1) < x(2) < ... < x(n)
    % x(j) is the center of cell I_j = [x(j)-dx/2,x(j)+dx/2]
    % size(x) = [1,n]

    x = linspace(xleft,xright,n+1);
    dx = x(2)-x(1);
    x = x(1:end-1) + dx / 2;
end
