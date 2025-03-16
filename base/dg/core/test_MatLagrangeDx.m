function test_MatLagrangeDx()
    % Test suite for MatLagrangeDx class (derivative of Lagrange basis functions)

    fprintf('Running tests for MatLagrangeDx...\n');

    % Test case 1: Construct MatLagrangeDx with a set of points
    points = [-1, 0, 1];
    basisDx = MatLagrangeDx(points);
    % x-1/2, -2x, x+1/2

    assert(isa(basisDx, 'MatLagrangeDx'), 'Failed to create MatLagrangeDx object.');
    assert(length(basisDx.funcs) == length(points), 'Incorrect number of derivative basis functions stored.');

    fprintf('Test 1 passed: MatLagrangeDx constructor works correctly.\n');

    % Test case 2: Evaluate the derivative of the Lagrange polynomials at test points
    x = linspace(-1, 1, 11)';  % Test points (column vector)
    du = basisDx.eval(x, length(points));  % Evaluate derivative basis functions

    % Validate the size of the result
    assert(size(du, 1) == length(x) && size(du, 2) == length(points), 'eval function returned incorrect matrix size.');

    % Manually compute the expected derivatives of the Lagrange polynomials at x
    expected_du = [
        -1.5, 2., -0.5;
        -1.3, 1.6, -0.3;
        -1.1, 1.2, -0.1;
        -0.9, 0.8, 0.1;
        -0.7, 0.4, 0.3;
        -0.5, 0., 0.5;
        -0.3, -0.4, 0.7;
        -0.1, -0.8, 0.9;
        0.1, -1.2, 1.1;
        0.3, -1.6, 1.3;
        0.5, -2., 1.5
        ];

    % Validate results
    assert(all(abs(du(:) - expected_du(:)) < 1e-6), 'eval function returned incorrect values for derivative basis functions.');

    fprintf('Test 2 passed: eval function computes correct Lagrange derivative polynomials.\n');

    % Test case 3: Verify eval handles row vectors correctly
    x_row = linspace(-1, 1, 11);  % Row vector input
    du_row = basisDx.eval(x_row, length(points));
    expected_du_row = expected_du';

    assert(all(abs(du_row(:) - expected_du_row(:)) < 1e-6), 'eval function does not handle row vectors correctly.');

    fprintf('Test 3 passed: eval function handles row vectors correctly.\n');

    % Test case 4: Verify eval function with large number of points
    points_large = linspace(-1, 1, 20);
    basisDx_large = MatLagrangeDx(points_large);
    x_large = linspace(-1, 1, 50)';
    du_large = basisDx_large.eval(x_large, length(points_large));

    % Validate the result for larger input
    assert(size(du_large, 1) == length(x_large) && size(du_large, 2) == length(points_large), 'eval function returned incorrect size for large input.');

    fprintf('Test 4 passed: eval function works with large number of points.\n');

    % Test case 5: Invalid constructor input (fewer than two points)
    try
        MatLagrangeDx(1);
        error('Test 5 failed: Constructor should reject fewer than two points.');
    catch ME
        assert(strcmp(ME.identifier, 'MatLagrangeDx:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    fprintf('Test 5 passed: Constructor correctly rejects invalid input.\n');

    fprintf('All tests passed successfully!\n');
end
