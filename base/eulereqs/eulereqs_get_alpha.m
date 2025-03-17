function alpha = eulereqs_get_alpha(uh)
    % size(uh) = [3,n] 每一列对应三个分量
    assert(size(uh,1) == 3);

    [rho,u,p] = eulereqs_trans2raw(uh(1,:),uh(2,:),uh(3,:)); % row vector
    gamma = 1.4;
    c = sqrt(gamma * p ./ rho);
    alpha = max([abs(u-c); abs(u); abs(u+c)]); % max on each column
end
