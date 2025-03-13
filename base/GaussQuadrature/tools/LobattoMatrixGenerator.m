classdef LobattoMatrixGenerator
    properties(SetAccess = private)
        n % 实际的节点数
        points
        weights
    end

    methods
        function obj = LobattoMatrixGenerator(n)
            % 构造方法
            [obj.points, obj.weights] = gausslobatto(n);
            obj.n = n;
        end

        function M = Eval(obj, x)
            % 计算拉格朗日基函数在所有求值点的值
            % 输入：x - 要求值的点（在[-1,1]范围内的）（列向量）
            % 输出：M - 拉格朗日基函数值的矩阵

            if nargin < 2
                x = obj.points; % 如果未提供 x，默认在 Gauss-Lobatto 节点处计算
            end

            if size(x, 2) ~= 1
                error('x must be a column vector');
            end

            nx = length(x);
            M = zeros(nx, obj.n);

            % 拉格朗日基函数的定义
            for i = 1:obj.n
                li = ones(nx, 1);
                for j = 1:obj.n
                    if i ~= j
                        li = li .* (x - obj.points(j)) / (obj.points(i) - obj.points(j));
                    end
                end
                M(:, i) = li;
            end
        end

        function DM = EvalDx(obj, x)
            % 计算拉格朗日基函数的导数在所有求值点的值
            % 输入：x - 要求值的点（在[-1,1]范围内的）（列向量）
            % 输出：DM - 拉格朗日基函数导数值的矩阵

            if nargin < 2
                x = obj.points; % 如果未提供 x，默认在 Gauss-Lobatto 节点处计算
            end

            if size(x, 2) ~= 1
                error('x must be a column vector');
            end

            nx = length(x);
            DM = zeros(nx, obj.n);

            % 计算拉格朗日基函数导数
            for i = 1:obj.n
                for k = 1:nx
                    xi = x(k);
                    sum_deriv = 0;
                    for j = 1:obj.n
                        if j ~= i
                            prod_term = 1;
                            for m = 1:obj.n
                                if m ~= i && m ~= j
                                    prod_term = prod_term * (xi - obj.points(m)) / (obj.points(i) - obj.points(m));
                                end
                            end
                            sum_deriv = sum_deriv + prod_term / (obj.points(i) - obj.points(j));
                        end
                    end
                    DM(k, i) = sum_deriv;
                end
            end
        end
    end

end
