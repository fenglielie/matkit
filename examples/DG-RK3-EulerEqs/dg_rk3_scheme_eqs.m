function u = dg_rk3_scheme_eqs(u, dx, tend, f, fhat, get_alpha, pk, gk, basis, basis_dx, dim, is_riemann)
    % dg_rk3_scheme_eqs
    %
    % INPUT:
    %   u           - Initial solution, must be a numeric vector or matrix.
    %   dx          - Spatial step size, must be a non-negative scalar.
    %   tend        - Final time, must be a non-negative scalar.
    %   f           - Flux function handle, defined as f(u).
    %   fhat        - Numerical flux function handle, defined as fhat(u_L, u_R, c).
    %   get_alpha   - Function handle, defined as get_alpha(u).
    %   pk          - Polynomial order, must be a positive integer.
    %   gk          - Number of Gauss quadrature points, must be a positive integer.
    %   basis       - Basis function object, must be an instance of MatBase or its subclass.
    %   basis_dx    - Derivative of the basis function object, must be an instance of MatBase or its subclass.
    %   dim         - Dimension of the equation, must be a positive integer.
    %   is_riemann  - Flag for Riemann problem, must be a logical scalar.
    %
    % OUTPUT:
    %   u           - Numerical solution

    assert(isnumeric(u) && (isvector(u) || ismatrix(u)), 'u must be a numeric vector or matrix.');
    assert(isscalar(dx) && dx >= 0, 'dx must be a non-negative scalar.');
    assert(isscalar(tend) && tend >= 0, 'tend must be a non-negative scalar.');
    assert(isa(f, 'function_handle'), 'f must be a function handle.');
    assert(isa(fhat, 'function_handle'), 'fhat must be a function handle.');
    assert(isa(get_alpha, 'function_handle'), 'get_alpha must be a function handle.');
    assert(isnumeric(pk) && isscalar(pk) && pk >= 0 && mod(pk, 1) == 0, 'pk must be a non-negative integer.');
    assert(isnumeric(gk) && isscalar(gk) && gk > 0 && mod(gk, 1) == 0, 'gk must be a positive integer.');
    assert(isa(basis, 'MatBase'), 'basis must be an object of class MatBase or its subclass.');
    assert(isa(basis_dx, 'MatBase'), 'basis_dx must be an object of class MatBase or its subclass.');
    assert(isnumeric(dim) && isscalar(dim) && dim > 0 && mod(dim, 1) == 0, 'dim must be a positive integer.');
    assert(islogical(is_riemann) && isscalar(is_riemann), 'is_riemann must be a logical scalar (true or false).');

    assert(2 * gk >= basis.funcs_num, 'insufficient precision of numerical quadrature formula');
    [points, weights] = gauss_legendre(gk);

    M = basis.eval(points, pk + 1); % size = [gk, pk+1]
    W = diag(weights); % size = [gk, gk]
    InvMass = inv(dx / 2 * M' * W * M); % size = [pk+1, pk+1]
    DM = 2 / dx * basis_dx.eval(points, pk + 1); % size = [gk, pk+1]

    vl = basis.eval(-1, pk + 1); % column vector size = [pk+1, 1]
    vc = basis.eval(0, pk + 1);
    vr = basis.eval(1, pk + 1);

    params = struct();
    params.vl = vl;
    params.vc = vc;
    params.vr = vr;

    params.Md = kron(speye(dim), M); % size = [d*gk, d*(pk+1)]
    params.Wd = kron(speye(dim), W); % size = [d*gk, d*gk]
    params.InvMassd = kron(speye(dim), InvMass); % size = [d*(pk+1), d*(pk+1)]
    params.DMd = kron(speye(dim), DM); % size = [d*gk, d*(pk+1)]
    params.vld = kron(speye(dim), vl); % size = [d*(pk+1), d]
    params.vcd = kron(speye(dim), vc);
    params.vrd = kron(speye(dim), vr);

    params.dim = dim;
    params.is_riemann = is_riemann;

    tnow = 0;

    while tnow < tend
        uh_mid = params.vcd' * u; % size(u) = [d*(pk+1), n], size(uh_mid) = [d, n]
        alpha = get_alpha(uh_mid);
        global_alpha = max(alpha);

        dt = 1 / ((2 * pk + 3) * global_alpha) * dx ^ (max((pk + 1) / 3, 1));
        dt = min([dt, tend - tnow]);

        u1 = u + dt * L_op(u, dx, f, fhat, get_alpha, params);
        u2 = (3/4) * u + (1/4) * (u1 + dt * L_op(u1, dx, f, fhat, get_alpha, params));
        u3 = (1/3) * u + (2/3) * (u2 + dt * L_op(u2, dx, f, fhat, get_alpha, params));
        u = u3;

        tnow = tnow + dt;
    end

end

function result = L_op(u, dx, f, fhat, get_alpha, params)
    % size(u) = [d*(pk+1), n]

    ul = params.vld' * u; % size = [d, n]
    ur = params.vrd' * u;

    alpha_l = get_alpha(ul); % size = [1, n]
    alpha_r = get_alpha(ur);

    lf_alpha = max([circshift(alpha_r, 1); alpha_l]); % size = [1, n]
    rf_alpha = max([alpha_r; circshift(alpha_l, -1)]);

    fhat_l = fhat(circshift(ur, 1, 2), ul, lf_alpha); % size = [d, n]
    fhat_r = fhat(ur, circshift(ul, -1, 2), rf_alpha);

    qd = params.Md * u; % size = [d*gk, n]
    main = dx / 2 * (params.DMd') * params.Wd * f(qd); % size = [d*(pk+1), n]

    left_boundary_cs = cell(params.dim, 1);
    right_boundary_cs = cell(params.dim, 1);

    for ii = 1:params.dim
        left_boundary_cs{ii} = params.vl .* fhat_l(ii, :); % size(vl) = [pk+1, 1]
        right_boundary_cs{ii} = params.vr .* fhat_r(ii, :);
    end

    left_boundary = cell2mat(left_boundary_cs); % size = [d*(pk+1), n]
    right_boundary = cell2mat(right_boundary_cs);

    result = params.InvMassd * (main - right_boundary + left_boundary); % size = [d*(pk+1), n]

    % Riemann boundary condition
    if params.is_riemann
        result(:, 1) = 0;
        result(:, end) = 0;
    end

end
