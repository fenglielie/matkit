classdef MatLegendre < MatBase
    % MatLegendre: A class that provides Legendre polynomial basis functions.
    %
    % Constructor:
    %   obj = MatLegendre(n) - Generates the first 'n' Legendre polynomials.
    %
    % EXAMPLE:
    %   basis = MatLegendre(5);
    %   x = linspace(-1, 1, 10);
    %   u = basis.eval(x, 5);
    %
    % NOTE:
    %   p0(x) = 1
    %   p1(x) = x
    %   p2(x) = (1/2)*(3*x^2 - 1)
    %   p3(x) = (1/2)*(5*x^3 - 3*x)
    %   p4(x) = (1/8)*(35*x^4 - 30*x^2 + 3)

    methods
        function obj = MatLegendre(n)
            % Constructor for MatLegendre
            %
            % Generates the first 'n' Legendre polynomials as basis functions.
            %
            % INPUT:
            %   n       - Number of Legendre polynomials to generate.
            %
            % EXAMPLE:
            %   basis = MatLegendre(5);

            if ~isscalar(n) || n < 1 || round(n) ~= n
                error('MatLegendre:InvalidInput', 'n must be a positive integer.');
            end

            % Generate Legendre polynomial function handles
            funcs = MatLegendre.generateLegendreFuncs(n);

            % Call parent constructor
            obj@MatBase(funcs);
        end
    end

    methods(Static)
        function funcs = generateLegendreFuncs(n)
            % Generate the first 'n' Legendre polynomial functions
            %
            % INPUT:
            %   n       - Number of polynomials to generate
            %
            % OUTPUT:
            %   funcs   - Cell array of function handles

            % funcs = cell(1, n);
            %
            % % Define symbolic variable for computing polynomials
            % syms x;
            % P = sym(zeros(1, n)); % Symbolic storage
            %
            % % Compute first two polynomials manually
            % P(1) = 1;
            % if n > 1
            %     P(2) = x;
            % end
            %
            % % Compute remaining polynomials using recurrence relation
            % for k = 3:n
            %     P(k) = ((2*k - 3) * x * P(k-1) - (k - 2) * P(k-2)) / (k - 1);
            % end
            %
            % % Convert symbolic expressions to function handles
            % for k = 1:n
            %     funcs{k} = matlabFunction(P(k), 'Vars', x);
            % end

            funcs = cell(1, n);
            for k = 1:n
                funcs{k} = @(x) legendreP(k-1, x);
            end
        end
    end
end
