classdef LegendreMatrixGenerator
    properties(SetAccess = private)
        n % 实际的节点数
        points
        weights
    end

    methods
        function obj = LegendreMatrixGenerator(n)
            % 构造方法
            [obj.points, obj.weights] = gauss_legendre(n);
            obj.n = n;
        end

        function M = eval(obj,x)
            % 计算勒让德正交基函数在所有求值点的值
            % 输入：x - 要求值的点（在[-1,1]范围内的）（列向量）
            % 输出：M - 勒让德正交基函数值的矩阵

            if nargin < 2
                x = obj.points;
            end

            if size(x,2) ~= 1
                error('x must be a row vector');
            end

            nx = length(x);
            M = zeros(nx,obj.n);
            for ii = 1:obj.n
                M(:, ii) = legendreP(ii-1, x);
            end
        end

        function DM = eval_dx(obj,x)
            % 计算勒让德正交基函数的导数在所有求值点的值
            % 输入：x - 要求值的点（在[-1,1]范围内的）（列向量）
            % 输出：DM - 拉勒让德正交基函数导数值的矩阵

            if nargin < 2
                x = obj.points;
            end

            if size(x,2) ~= 1
                error('x must be a row vector');
            end

            nx = length(x);
            DM = zeros(nx,obj.n);
            % 计算勒让德基函数导数值
            for m = 1:obj.n-1
                % 使用递归公式计算导数 P'_n(x)
                for ii = 1:nx
                    xi = x(ii);

                    % 处理 x = 1,-1 的特殊情况
                    if abs(xi - 1) < 1e-12 || abs(xi + 1) < 1e-12
                        if m == 1
                            % P'_1(x) = 1 for x = +1,-1
                            DM(ii,m + 1) = 1;
                        else
                            % n > 1, P'_n(+1,-1) = n * (n + 1) / 2 * (-1)^(n+1)
                            DM(ii,m + 1) = m * (m + 1) / 2 * (-1)^(m + 1) * sign(xi);
                        end
                    else
                        % P'_n(x) = n / (1 - x^2) * (P_{n-1}(x) - x * P_n(x))
                        Pn = legendreP(m, xi);
                        Pn_1 = legendreP(m - 1, xi);
                        DM(ii,m + 1) = m / (1 - xi^2) * (Pn_1 - xi * Pn);
                    end
                end
            end

            % 第一列 (P'_0) 为零，因为 P_0(x) 是常数
            DM(:, 1) = 0;
        end
    end

end
