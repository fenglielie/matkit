请为我接下来提供的MATLAB函数补充详细的输入输出参数注释，注释使用英文。
每个参数注释需要说明它的类型、作用以及任何限制条件，例如是否为标量、是否为正数、是否为整数、是否只允许是布尔值、是否为函数句柄等。
对每个参数的说明不要过于复杂，控制在一行以内。

同时，请使用assert进行参数的严格检查，确保输入的正确性。

注释和参数检查应该遵循清晰且一致的风格，类似于以下的例子：

```matlab
function u = dg_rk3_scheme(u, dx, tend, f, fhat, df, pk, gk, basis, basis_dx)
    % INPUT:
    %   u         - Initial solution, must be a numeric vector or matrix.
    %   dx        - Spatial step size, must be a non-negative scalar.
    %   tend      - Final time, must be a non-negative scalar.
    %   f         - Flux function handle, defined as f(u).
    %   fhat      - Numerical flux function handle, defined as fhat(u_L, u_R, c).
    %   df        - Derivative of the flux function, defined as df(u).
    %   pk        - Polynomial order, must be a positive integer.
    %   gk        - Number of Gauss quadrature points, must be a positive integer.
    %   basis     - Basis function object, must be an instance of MatBase or its subclass.
    %   basis_dx  - Derivative of the basis function object, must be an instance of MatBase or its subclass.
    %
    % OUTPUT:
    %   u         - Numerical solution

    assert(isnumeric(u) && (isvector(u) || ismatrix(u)), 'u must be a numeric vector or matrix.');
    assert(isscalar(dx) && dx >= 0, 'dx must be a non-negative scalar.');
    assert(isscalar(tend) && tend >= 0, 'tend must be a non-negative scalar.');
    assert(isa(f, 'function_handle'), 'f must be a function handle.');
    assert(isa(fhat, 'function_handle'), 'fhat must be a function handle.');
    assert(isa(df, 'function_handle'), 'df must be a function handle.');
    assert(isnumeric(pk) && isscalar(pk) && pk > 0 && mod(pk,1) == 0, 'pk must be a positive integer.');
    assert(isnumeric(gk) && isscalar(gk) && gk > 0 && mod(gk,1) == 0, 'gk must be a positive integer.');
    assert(isa(basis, 'MatBase'), 'basis must be an object of class MatBase or its subclass.');
    assert(isa(basis_dx, 'MatBase'), 'basis_dx must be an object of class MatBase or its subclass.');

    ...

end
```

请按照此格式为我的函数编写输入输出参数的注释和参数检查代码，并确保注释内容规范清晰。
