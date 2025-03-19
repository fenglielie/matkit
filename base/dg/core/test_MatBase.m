function test_MatBase()
    % Test suite for MatBase class

    fprintf('Running tests for MatBase...\n');

    % Test case 1: Construct MatBase with simple basis functions
    funcs = {@(x) ones(size(x)), @(x) x, @(x) x.^2};
    basis = MatBase(funcs);

    % 验证基函数存储正确
    assert(isa(basis, 'MatBase'), 'Failed to create MatBase object.');
    assert(basis.funcs_num == length(funcs), 'Incorrect number of basis functions stored.');

    fprintf('Test 1 passed: MatBase constructor works correctly.\n');

    % Test case 2: Evaluate the basis functions at test points
    x = linspace(-1, 1, 5)';  % Test points (column vector)
    n = 3;
    u = basis.eval(x, n);

    % expected theoretical values of basis functions at x
    expected_u = [
        1, -1, 1;
        1, -0.5, 0.25;
        1, 0, 0;
        1, 0.5, 0.25;
        1, 1, 1
    ];

    % Validate results
    assert(size(u, 1) == length(x) && size(u, 2) == n, 'eval function returned incorrect matrix size.');
    assert(all(abs(u(:) - expected_u(:)) < 1e-6), 'eval function returned incorrect values.');

    fprintf('Test 2 passed: eval function computes correct values.\n');

    % Test case 3: Verify eval handles row vectors correctly
    x_row = linspace(-1, 1, 5);  % Row vector input
    u_row = basis.eval(x_row, n);

    assert(isequal(u_row, expected_u'), 'eval function does not handle row vectors correctly.');

    fprintf('Test 3 passed: eval function handles row vectors correctly.\n');

    % Test case 4: Invalid input (n too large)
    try
        basis.eval(x, 4);  % 超过funcs_num的索引
        error('Test 4 failed: eval should have thrown an error for n > funcs_num.');
    catch ME
        assert(strcmp(ME.identifier, 'MatBase:InvalidInput'), 'Incorrect error handling for invalid input.');
    end

    fprintf('Test 4 passed: eval correctly handles n > funcs_num.\n');

    fprintf('All tests passed successfully!\n');
end
