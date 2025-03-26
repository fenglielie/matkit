function result = order(xlist, ylist)
    % ORDER Computes the local order of convergence based on given data points.
    %
    % This function calculates the order of convergence for a given sequence
    % of x-values (xlist) and corresponding y-values (ylist). The order is
    % determined using the formula:
    %
    %   order = -log(y_{k+1} / y_k) / log(x_{k+1} / x_k)
    %
    % INPUT:
    %   xlist   - A numeric vector containing x-values.
    %   ylist   - A numeric vector containing y-values corresponding to xlist.
    %
    % OUTPUT:
    %   result  - A vector containing the computed order values for each pair of
    %            consecutive (x, y) points.
    %
    % EXAMPLE:
    %   order([10, 20, 40], [0.5, 0.25, 0.125])   => [1, 1]
    %   order([10; 20; 40]', [0.5; 0.25; 0.125])  => [1; 1]

    assert(isvector(xlist) && isnumeric(xlist), 'xlist must be a numeric vector.');
    assert(isvector(ylist) && isnumeric(ylist), 'ylist must be a numeric vector.');
    assert(all(size(xlist) == size(ylist)), 'xlist and ylist must have the same size.');
    assert(length(xlist) >= 2, 'xlist and ylist must have at least two elements.');

    num = length(xlist) - 1;
    result = zeros(num, 1);
    for w = 1:num
        result(w) = -log(ylist(w + 1) / ylist(w)) / log(xlist(w + 1) / xlist(w));
    end

    if size(xlist, 1) == 1
        result = result';
    end
end
