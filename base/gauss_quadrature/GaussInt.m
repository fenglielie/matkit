classdef GaussInt
    % GAUSSINT Implements Gaussian quadrature integration methods.
    %
    % This class provides static methods for numerical integration using
    % Gaussian quadrature with fixed (3-point, 5-point) or arbitrary nodes.
    %
    % Methods:
    %   gauss3  - 3-point Gauss-Legendre quadrature
    %   gauss5  - 5-point Gauss-Legendre quadrature
    %   gaussn  - n-point Gauss-Legendre quadrature using predefined nodes
    %
    % All methods take a function handle f(x) and integrate it over [xleft, xright].

    methods (Static)

        function result = gauss3(f, xleft, xright)
            % GAUSS3 3-point Gauss-Legendre quadrature for numerical integration.
            %
            % INPUT:
            %   f      - Function handle @(x) to integrate.
            %   xleft  - Left integration boundary.
            %   xright - Right integration boundary.
            %
            % OUTPUT:
            %   result - Approximated integral of f over [xleft, xright].

            assert(isa(f, 'function_handle'), 'f must be a function handle.');
            assert(isnumeric(xleft) && isnumeric(xright) && xleft < xright, ...
            'xleft must be less than xright and both must be numeric.');

            % Gauss-Legendre 3-point nodes and weights
            weights = [5/9, 8/9, 5/9]';
            nodes = [-sqrt(3/5), 0, sqrt(3/5)]';

            % [-1, 1] <-> [xleft, xright]
            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

        function result = gauss5(f, xleft, xright)
            % GAUSS5 5-point Gauss-Legendre quadrature for numerical integration.
            %
            % INPUT:
            %   f      - Function handle @(x) to integrate.
            %   xleft  - Left integration boundary.
            %   xright - Right integration boundary.
            %
            % OUTPUT:
            %   result - Approximated integral of f over [xleft, xright].

            assert(isa(f, 'function_handle'), 'f must be a function handle.');
            assert(isnumeric(xleft) && isnumeric(xright) && xleft < xright, ...
            'xleft must be less than xright and both must be numeric.');

            % Gauss-Legendre 5-point nodes and weights
            weights = [0.2369268850561891, 0.4786286704993665, 0.5688888888888889, ...
                           0.4786286704993665, 0.2369268850561891]';
            nodes = [-0.9061798459386640, -0.5384693101056831, 0, ...
                         0.5384693101056831, 0.9061798459386640]';

            % [-1, 1] <-> [xleft, xright]
            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

        function result = gaussn(n, f, xleft, xright)
            % GAUSSN n-point Gauss-Legendre quadrature.
            %
            % INPUT:
            %   n      - Number of quadrature points (positive integer).
            %   f      - Function handle @(x) to integrate.
            %   xleft  - Left integration boundary.
            %   xright - Right integration boundary.
            %
            % OUTPUT:
            %   result - Approximated integral of f over [xleft, xright].

            assert(isa(f, 'function_handle'), 'f must be a function handle.');
            assert(isnumeric(n) && isscalar(n) && n >= 2 && mod(n, 1) == 0, 'n must be a positive integer, n >= 2');
            assert(isnumeric(xleft) && isnumeric(xright) && xleft < xright, ...
            'xleft must be less than xright and both must be numeric.');

            % Gauss-Legendre n-point nodes and weights
            [nodes, weights] = gauss_legendre(n);

            % [-1, 1] <-> [xleft, xright]
            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

    end

end
