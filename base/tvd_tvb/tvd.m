function result = tvd(a1, a2, a3, ~)
    % TVD Computes a total variation diminishing (TVD) limited slope.
    %
    % INPUT:
    %   a1, a2, a3 - Arrays of the same size, typically slope candidates
    %   ~          - Unused scalar parameter (e.g., h), kept for interface compatibility with tvb
    %
    % OUTPUT:
    %   result     - Limited slope array of the same size as inputs
    %
    % DESCRIPTION:
    %   This function applies a simple TVD limiter. It returns the minimum
    %   of (a1, a2, a3) when all three are positive, and the maximum of them
    %   when all are negative. In all other cases (i.e., mixed signs), zero is returned.
    %
    % EXAMPLE:
    %   a1 = [1, 0, -1]; a2 = [2, 0, -2]; a3 = [3, 0, -3];
    %   r = tvd(a1, a2, a3, []); % [1, 0, -1]

    assert(isnumeric(a1) && isnumeric(a2) && isnumeric(a3), 'a1, a2, and a3 must be numeric arrays.');
    assert(isequal(size(a1), size(a2), size(a3)), 'a1, a2, and a3 must have the same size.');

    pos_mask = (a1 > 0) & (a2 > 0) & (a3 > 0);
    neg_mask = (a1 < 0) & (a2 < 0) & (a3 < 0);

    result = zeros(size(a1));

    result(pos_mask) = min(min(a1(pos_mask), a2(pos_mask)), a3(pos_mask));
    result(neg_mask) = max(max(a1(neg_mask), a2(neg_mask)), a3(neg_mask));
end
