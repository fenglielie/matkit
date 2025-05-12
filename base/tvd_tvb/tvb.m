function f = tvb(m)
    % TVB Returns a limiter function with bounded total variation (TVB).
    %
    % INPUT:
    %   m       - TVB parameter (non-negative scalar), controls threshold for limiting
    %
    % OUTPUT:
    %   f       - Function handle that accepts (a1, a2, a3, h) and returns limited result
    %
    % DESCRIPTION:
    %   The returned function applies the TVB limiter to a1 based on threshold m * h^2.
    %   When |a1| < m * h^2, the result is a1 itself (no limiting).
    %   Otherwise, the result is computed using the TVD limiter.
    %
    % EXAMPLE:
    %   f = tvb(1.0);
    %   result = f(a1, a2, a3, h);

    assert(isnumeric(m) && isscalar(m) && m >= 0, 'm must be a non-negative scalar.');

    f = @(a1, a2, a3, h) tvb_inner(a1, a2, a3, h, m);
end

function result = tvb_inner(a1, a2, a3, h, m)
    % TVB_INNER Internal function for applying TVB limiting.
    %
    % INPUT:
    %   a1, a2, a3      - Numeric arrays of the same size
    %   h               - Mesh size (positive scalar)
    %   m               - TVB parameter (non-negative scalar)
    %
    % OUTPUT:
    %   result          - Limited array of the same size as a1
    %
    % DESCRIPTION:
    %   uses a1 if |a1| < m * h^2, else falls back to TVD limiter.

    assert(isnumeric(a1) && isnumeric(a2) && isnumeric(a3), 'a1, a2, and a3 must be numeric arrays.');
    assert(isequal(size(a1), size(a2), size(a3)), 'a1, a2, and a3 must have the same size.');
    assert(isnumeric(h) && isscalar(h) && h > 0, 'h must be a positive scalar.');
    assert(isnumeric(m) && isscalar(m) && m >= 0, 'm must be a non-negative scalar.');

    condition = abs(a1) < m * h ^ 2;
    result = zeros(size(a1));

    result(condition) = a1(condition);
    result(~condition) = tvd(a1(~condition), a2(~condition), a3(~condition), h);
end
