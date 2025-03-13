clc;
clear;
close all;

func = @(n) gausslegendre(n);
args = @(n) deal(1,2*n-1);

% func = @(n) gausslobatto(n);
% args = @(n) deal(2,2*n-3);

nRange = 2:15;
allPassed = true;

for n = nRange
    [x, w] = func(n);
    [n_min,n_max] = args(n);

    fprintf('n = %d\n', n);
    fprintf('Nodes:   ');
    disp(mat2str(x));
    fprintf('Weights: ');
    disp(mat2str(w));
    disp(' ')

    for k = n_min:(n_max+1)
        f = @(x) x.^k;

        if mod(k, 2) == 0
            exactIntegral = 2 / (k + 1);
        else
            exactIntegral = 0;
        end

        numericalIntegral = sum(f(x) .* w);

        error = abs(numericalIntegral - exactIntegral);
        if k <= n_max && error >= 10*eps
            allPassed = false;
            fprintf("[Failed] k = %d, ord = %d, error = %.12f\n", n,k, error);
        end
    end
end

if allPassed
    fprintf('All tests passed.\n');
else
    fprintf('Some tests failed.\n');
end
