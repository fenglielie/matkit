function [res_ul, res_ur] = central5(u)
    % 五阶中心差分（用于对比WENO5）
    % 输入要求u为行向量

    % 线性权重
    d_l = [3.0 / 10; 3.0 / 5; 1.0 / 10];
    d_r = [1.0 / 10; 3.0 / 5; 3.0 / 10];

    ul_mat = [circshift(u, 2); circshift(u, 1); u];
    u_mat = [circshift(u, 1); u; circshift(u, -1)];
    ur_mat = [u; circshift(u, -1); circshift(u, -2)];

    % 预定义插值系数矩阵
    coeff_l = [-1/6,  5/6,  1/3;
        1/3,  5/6, -1/6;
        11/6, -7/6,  1/3];

    coeff_r = [ 1/3, -7/6,  11/6;
        -1/6,  5/6,   1/3;
        1/3,  5/6,  -1/6];

    % 计算左右重构值
    u_l =  [coeff_l(1,:) * ul_mat;
        coeff_l(2,:) * u_mat;
        coeff_l(3,:) * ur_mat];
    u_r = [coeff_r(1,:) * ul_mat;
        coeff_r(2,:) * u_mat;
        coeff_r(3,:) * ur_mat];

    % 最终重构结果
    res_ul = sum(d_l .* u_l, 1);
    res_ur = sum(d_r .* u_r, 1);
end
