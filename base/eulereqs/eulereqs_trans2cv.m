function [v1,v2,v3] = eulereqs_trans2cv(rho,u,p)
    % 从原始变量 [rho,u,p] 改为守恒变量 [v1,v2,v3]
    % 尺寸保持和输入的一致

    gamma = 1.4;
    v1 = rho;
    v2 = rho .* u;
    v3 = 1 / (gamma - 1) * p + 0.5 * rho .* u.^2;
end
