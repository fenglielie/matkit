classdef GaussInt

    methods(Static)
        function result = gauss5(f, xleft, xright)
            weights = [0.2369268850561891, 0.4786286704993665, 0.5688888888888889, 0.4786286704993665, 0.2369268850561891]';
            nodes = [-0.9061798459386640, -0.5384693101056831, 0, 0.5384693101056831, 0.9061798459386640]';

            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

        function result = gauss3(f, xleft, xright)
            weights = [5/9, 8/9, 5/9]';
            nodes = [-sqrt(3/5), 0, sqrt(3/5)]';

            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

        function result = gaussn(n, f, xleft, xright)
            [nodes, weights] = gauss_legendre(n);

            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end

        function result = gauss(nodes, weights, f, xleft, xright)
            half_width = (xright - xleft) / 2;
            midpoint = (xleft + xright) / 2;
            nodes_local = midpoint + half_width * nodes;

            result = half_width * sum(weights .* f(nodes_local));
        end
    end
end
