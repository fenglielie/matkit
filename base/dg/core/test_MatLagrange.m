function test_MatLagrange()
    % Test suite for MatLagrange class

    fprintf('Running tests for MatLagrange...\n');

    % Test case 1: Construct MatLagrange with a set of points
    points = [-1, 0, 1];
    basis = MatLagrange(points);
    % x(x-1)/2, 1-x^2, x(x+1)/2

    assert(isa(basis, 'MatLagrange'), 'Failed to create MatLagrange object.');
    assert(length(basis.funcs) == length(points), 'Incorrect number of basis functions stored.');

    fprintf('Test 1 passed: MatLagrange constructor works correctly.\n');

    % Test case 2: Evaluate the Lagrange polynomials at test points
    x = linspace(-1, 1, 11)';  % Test points (column vector)
    u = basis.eval(x, length(points));  % Evaluate basis functions

    % Validate the size of the result
    assert(size(u, 1) == length(x) && size(u, 2) == length(points), 'eval function returned incorrect matrix size.');

    % Manually compute the expected values of the Lagrange polynomials at x
    expected_u = [
        1., 0., 0.;
        0.72, 0.36, -0.08;
        0.48, 0.64, -0.12;
        0.28, 0.84, -0.12;
        0.12, 0.96, -0.08;
        0., 1., 0.;
        -0.08, 0.96, 0.12;
        -0.12, 0.84, 0.28;
        -0.12, 0.64, 0.48;
        -0.08, 0.36, 0.72;
        0., 0., 1.
        ];

    % Validate results
    assert(all(abs(u(:) - expected_u(:)) < 1e-6), 'eval function returned incorrect values.');

    fprintf('Test 2 passed: eval function computes correct Lagrange polynomials.\n');

    % Test case 3: Verify eval handles row vectors correctly
    x_row = linspace(-1, 1, 11);  % Row vector input
    u_row = basis.eval(x_row, length(points));
    expected_u_row = expected_u';

    assert(all(abs(u_row(:) - expected_u_row(:)) < 1e-6), 'eval function does not handle row vectors correctly.');

    fprintf('Test 3 passed: eval function handles row vectors correctly.\n');

    % Test case 4: Verify eval function with large number of points
    points_large = linspace(-1, 1, 20);
    basis_large = MatLagrange(points_large);
    x_large = linspace(-1, 1, 50)';
    u_large = basis_large.eval(x_large, length(points_large));

    % Validate the result for larger input
    assert(size(u_large, 1) == length(x_large) && size(u_large, 2) == length(points_large), 'eval function returned incorrect size for large input.');

    fprintf('Test 4 passed: eval function works with large number of points.\n');

    % Test case 5: Invalid constructor input (fewer than two points)
    try
        MatLagrange(1);
        error('Test 5 failed: Constructor should reject fewer than two points.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLagrange:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    fprintf('Test 5 passed: Constructor correctly rejects invalid input.\n');

    fprintf('All tests passed successfully!\n');
end
