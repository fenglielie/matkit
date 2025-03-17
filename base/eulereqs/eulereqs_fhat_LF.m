function f = eulereqs_fhat_LF(u_minus, u_plus, alpha)
    f = 0.5 * (eulereqs_f(u_minus) + eulereqs_f(u_plus)) - 0.5 * alpha .* (u_plus - u_minus);
end
