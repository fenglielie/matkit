function test_MatLegendreDx()
    % Test suite for MatLegendreDx class

    fprintf('Running tests for MatLegendreDx...\n');

    % Test case 1: Construct MatLegendreDx with n = 5
    n = 5;
    basis = MatLegendreDx(n);
    assert(isa(basis, 'MatLegendreDx'), 'Failed to create MatLegendreDx object.');
    assert(basis.funcs_num == n, 'Incorrect number of basis functions stored.');

    fprintf('Test 1 passed: MatLegendreDx constructor works correctly.\n');

    % Test case 2: Evaluate the first 5 derivatives of Legendre polynomials at test points
    x = linspace(-1, 1, 5)';  % Test points (column vector)
    u = basis.eval(x, n);  % Evaluate derivatives of basis functions

    % Expected theoretical values of derivatives of Legendre polynomials at x
    expected_u = [
        0, 1, -3, 6, -10;
        0, 1, -1.5, 0.375, 1.5625;
        0, 1, 0, -(3/2), 0;
        0, 1, 1.5, 0.375, -1.5625;
        0, 1, 3, 6, 10
        ];  % Manually computed values of P'_0 to P'_4 at [-1, -0.5, 0, 0.5, 1]

    % Validate results
    assert(size(u,1) == length(x) && size(u,2) == n, 'eval function returned incorrect matrix size.');
    assert(all(abs(u(:) - expected_u(:)) < 1e-6), 'eval function returned incorrect values.');

    fprintf('Test 2 passed: eval function computes correct derivatives of Legendre polynomials.\n');

    % Test case 3: Verify eval handles row vectors correctly
    x_row = linspace(-1, 1, 5);  % Row vector input
    u_row = basis.eval(x_row, n);
    expected_u_row = expected_u';

    assert(all(abs(u_row(:) - expected_u_row(:)) < 1e-6), 'eval function does not handle row vectors correctly.');

    fprintf('Test 3 passed: eval function handles row vectors correctly.\n');

    % Test case 4: Invalid constructor input
    try
        MatLegendreDx(0);
        error('Test 4 failed: Constructor should reject n = 0.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendreDx:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    try
        MatLegendreDx(-3);
        error('Test 4 failed: Constructor should reject negative n.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendreDx:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    try
        MatLegendreDx(3.5);
        error('Test 4 failed: Constructor should reject non-integer n.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendreDx:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    fprintf('Test 4 passed: Constructor correctly rejects invalid inputs.\n');

    fprintf('All tests passed successfully!\n');
end
