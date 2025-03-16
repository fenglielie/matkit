function show_results(nums, error_l1, error_l2, error_inf)
    order_l1 = order(nums, error_l1);
    order_l2 = order(nums, error_l2);
    order_inf = order(nums, error_inf);

    fprintf('   n & error_l1 & order & error_l2 & order & error_linf & order \\\\ \n');
    fprintf('%4d & %.2e &   -  & %.2e &   -  & %.2e &   -  \\\\ \n', ...
        nums(1), error_l1(1), error_l2(1), error_inf(1));

    for cnt = 2:length(nums)
        fprintf('%4d & %.2e & %.2f & %.2e & %.2f & %.2e & %.2f \\\\ \n', ...
            nums(cnt), error_l1(cnt), order_l1(cnt-1), error_l2(cnt), order_l2(cnt-1), error_inf(cnt), order_inf(cnt-1));
    end
end
