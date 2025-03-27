function is_valid = check_valid_matrix(A, upper_bound)
    % CHECK_VALID_MATRIX Checks if a matrix is valid based on given conditions.
    %
    % This function verifies whether a given matrix A is valid according to two conditions:
    %   1. It does not contain NaN or Inf values.
    %   2. All elements are within the range [-upper_bound, upper_bound].
    %
    % INPUT:
    %   A               - A numeric matrix.
    %   upper_bound     - A positive scalar specifying the absolute upper bound for matrix elements.
    %
    % OUTPUT:
    %   is_valid        - A logical value (true or false) indicating whether A meets the conditions.
    %
    % EXAMPLE:
    %   check_valid_matrix([1, 2; 3, 4], 100)       % true
    %   check_valid_matrix([1, NaN; 3, 4], 100)     % false (contains NaN)
    %   check_valid_matrix([1, 200; 3, 4], 100)     % false (exceeds upper bound)

    assert(isnumeric(A) && ismatrix(A), 'A must be a numeric matrix.');
    assert(isnumeric(upper_bound) && isscalar(upper_bound) && upper_bound > 0, 'upper_bound must be positive.');

    if any(isnan(A(:))) || any(isinf(A(:)))
        is_valid = false;
        return;
    end

    if any(abs(A(:)) > upper_bound)
        is_valid = false;
        return;
    end

    is_valid = true;
end
