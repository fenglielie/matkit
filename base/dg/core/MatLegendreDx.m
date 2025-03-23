classdef MatLegendreDx < MatBase
    % MatLegendreDx: A class that provides Legendre polynomial derivatives.
    %
    % Constructor:
    %   obj = MatLegendreDx(n) - Generates the first 'n' Legendre polynomial derivatives.
    %
    % EXAMPLE:
    %   basis = MatLegendreDx(5);
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
        function obj = MatLegendreDx(n)
            % Constructor for MatLegendreDx
            %
            % Generates the first 'n' derivatives of Legendre polynomials.
            %
            % INPUT:
            %   n       - Number of Legendre polynomials to generate.
            %
            % EXAMPLE:
            %   basis = MatLegendreDx(5);

            if ~isscalar(n) || n < 1 || round(n) ~= n
                error('MatLegendreDx:InvalidInput', 'n must be a positive integer.');
            end

            % Generate the derivatives of Legendre polynomial function handles
            dfuncs = MatLegendreDx.generateLegendreDerivatives(n);

            % Call parent constructor
            obj@MatBase(dfuncs);
        end
    end

    methods(Static)
        function dfuncs = generateLegendreDerivatives(n)
            % Generate the first 'n' Legendre polynomial derivatives
            %
            % INPUT:
            %   n       - Number of polynomials to generate
            %
            % OUTPUT:
            %   dfuncs  - Cell array of derivative function handles

            % dfuncs = cell(1, n);
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
            % % Differentiate the polynomials
            % dP = diff(P, x);
            %
            % % Convert symbolic expressions to function handles
            % for k = 1:n
            %     dfuncs{k} = matlabFunction(dP(k), 'Vars', x);
            % end

            dfuncs = cell(1, n);
            syms x;

            for k = 1:n
                dP = diff(legendreP(k-1, x), x);
                dfuncs{k} = matlabFunction(dP, 'Vars', x);
            end
        end
    end
end
