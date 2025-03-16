function result = order(xlist, ylist)
    if length(xlist) ~= length(ylist)
        result = [];
        return;
    end

    num = length(xlist) - 1;
    result = zeros(1, num);

    for w = 1:num
        result(w) = -log(ylist(w + 1) / ylist(w)) / log(xlist(w + 1) / xlist(w));
    end
end
