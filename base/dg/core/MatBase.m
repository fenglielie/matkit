classdef MatBase < handle
    % MatBase: A base class for Discontinuous Galerkin (DG) basis functions.
    %
    % Properties:
    %   funcs      - Cell array of function handles representing the basis functions.
    %   funcs_num  - Number of basis functions.
    %
    % Methods:
    %   eval(x, n) - Evaluate the first 'n' basis functions at points 'x'.

    properties
        funcs      % Basis function list (cell array of function handles)
        funcs_num  % Number of basis functions
    end

    methods
        function obj = MatBase(funcs)
            % Constructor for MatBase
            %
            % Parameters:
            %   funcs - A cell array of function handles representing basis functions.
            %
            % Example:
            %   funcs = {@(x) x, @(x) x.^2, @(x) x.^3, @(x) sin(x)};
            %   basis = MatBase(funcs);

            if ~iscell(funcs) || isempty(funcs) || ~all(cellfun(@(f) isa(f, 'function_handle'), funcs))
                error('MatBase:InvalidInput', 'funcs must be a non-empty cell array of function handles.');
            end

            obj.funcs = funcs;
            obj.funcs_num = length(funcs);
        end

        function u = eval(obj, x, n)
            % Evaluate the first 'n' basis functions at points 'x'.
            %
            % Parameters:
            %   x - A vector of evaluation points in the range [-1, 1].
            %   n - The number of basis functions to evaluate.
            %
            % Returns:
            %   u - A matrix containing function values.
            %       - If x is a column vector (m, 1), returns an (m, n) matrix.
            %       - If x is a row vector (1, m), returns an (n, m) matrix.
            %
            % Example:
            %   funcs = {@(x) x, @(x) x.^2, @(x) x.^3};
            %   basis = MatBase(funcs);
            %   x = linspace(-1, 1, 5);
            %   u = basis.eval(x, 3);

            if ~isvector(x)
                error('MatBase:InvalidInput', 'x must be a vector.');
            end
            if n > obj.funcs_num
                error('MatBase:InvalidInput', 'n=%d exceeds available basis functions (%d).', n, obj.funcs_num);
            end

            % Preserve input shape
            is_row_vector = isrow(x);
            x_col = x(:);  % Ensure x is a column vector

            % Evaluate basis functions
            u = zeros(length(x_col), n);
            for i = 1:n
                u(:, i) = obj.funcs{i}(x_col);
            end

            % Restore original shape
            if is_row_vector
                u = u.';
            end
        end
    end
end
