function limiter_fn = tvb_limiter(tvb_m)

    if tvb_m < 0
        limiter_fn = @(ul_plus, u, ur_minus, dx) deal(ul_plus, ur_minus);
    else
        limiter_fn = @(ul_plus, u, ur_minus, dx) tvb_limiter_in(ul_plus, u, ur_minus, dx, tvb_m);
    end

end

function [ul_plus, ur_minus] = tvb_limiter_in(ul_plus, u, ur_minus, dx, tvb_m)
    uright = circshift(u, -1);
    uleft = circshift(u, 1);

    for w = 1:numel(u)
        ul_plus(w) = u(w) - TVB(u(w) - ul_plus(w), u(w) - uleft(w), uright(w) - u(w), dx, tvb_m);
        ur_minus(w) = u(w) + TVB(ur_minus(w) - u(w), u(w) - uleft(w), uright(w) - u(w), dx, tvb_m);
    end

end

% FUTURE: vectorize TVB/TVD function

% m > 0 -> TVB
% m = 0 -> TVD
function result = TVB(a1, a2, a3, h, m)

    if abs(a1) < m * h * h
        result = a1;
    else
        result = TVD(a1, a2, a3);
    end

end

function result = TVD(a1, a2, a3)

    if a1 > 0 && a2 > 0 && a3 > 0
        result = min([a1, a2, a3]);
    elseif a1 < 0 && a2 < 0 && a3 < 0
        result = max([a1, a2, a3]);
    else
        result = 0;
    end

end
