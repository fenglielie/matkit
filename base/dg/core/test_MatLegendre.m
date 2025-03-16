function test_MatLegendre()
    % Test suite for MatLegendre class

    fprintf('Running tests for MatLegendre...\n');

    % Test case 1: Construct MatLegendre with n = 5
    n = 5;
    basis = MatLegendre(n);
    assert(isa(basis, 'MatLegendre'), 'Failed to create MatLegendre object.');
    assert(basis.funcs_num == n, 'Incorrect number of basis functions stored.');

    fprintf('Test 1 passed: MatLegendre constructor works correctly.\n');

    % Test case 2: Evaluate the first 5 Legendre polynomials at test points
    x = linspace(-1, 1, 5)';  % Test points (column vector)
    u = basis.eval(x, n);  % Evaluate basis functions

    % Expected theoretical values of Legendre polynomials at x
    expected_u = [
        1, -1, 1, -1, 1 ;
        1., -0.5, -0.125, 0.4375, -0.289063 ;
        1, 0, -(1/2), 0, 3/8 ;
        1., 0.5, -0.125, -0.4375, -0.289063 ;
        1, 1, 1, 1, 1
        ]; % Manually computed values of P_0 to P_4 at [-1, -0.5, 0, 0.5, 1]

    % Validate results
    assert(size(u,1) == length(x) && size(u,2) == n, 'eval function returned incorrect matrix size.');
    assert(all(abs(u(:) - expected_u(:)) < 1e-6), 'eval function returned incorrect values.');


    fprintf('Test 2 passed: eval function computes correct Legendre polynomials.\n');

    % Test case 3: Verify eval handles row vectors correctly
    x_row = linspace(-1, 1, 5);  % Row vector input
    u_row = basis.eval(x_row, n);
    expected_u_row = expected_u';

    assert(all(abs(u_row(:) - expected_u_row(:)) < 1e-6), 'eval function does not handle row vectors correctly.');

    fprintf('Test 3 passed: eval function handles row vectors correctly.\n');

    % Test case 4: Invalid constructor input
    try
        MatLegendre(0);
        error('Test 4 failed: Constructor should reject n = 0.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendre:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    try
        MatLegendre(-3);
        error('Test 4 failed: Constructor should reject negative n.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendre:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    try
        MatLegendre(3.5);
        error('Test 4 failed: Constructor should reject non-integer n.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLegendre:InvalidInput'), 'Incorrect error handling for non-integer n.');
    end

    fprintf('Test 4 passed: Constructor correctly rejects invalid inputs.\n');

    fprintf('All tests passed successfully!\n');
end
