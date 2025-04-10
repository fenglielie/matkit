function print_center_msg(str, totalWidth)
    % PRINT_CENTER_MSG Prints a centered string with '=' padding.
    %
    % This function displays a string centered within a specified total width,
    % with spaces on both sides of the content and '=' characters as padding.
    %
    % INPUT:
    %   str        - The text to be displayed (char or string)
    %   totalWidth - The total output width (must be a positive scalar), default: 40

    if nargin < 2
        totalWidth = 40;
    end

    assert(ischar(str) || isstring(str), 'str must be a character array or string scalar.');
    assert(isnumeric(totalWidth) && isscalar(totalWidth) && totalWidth > 0,'totalWidth must be a positive scalar.');

    % Convert to character array
    str = char(str);

    % Construct content with space padding
    content = [' ', str, ' '];
    contentLength = numel(content);

    % Ensure totalWidth is at least as long as the content
    if totalWidth < contentLength
        totalWidth = contentLength;
    end

    % Compute padding lengths
    padding = totalWidth - contentLength;
    left = floor(padding / 2);
    right = padding - left;

    % Construct and display the final line
    line = [repmat('=', 1, left), content, repmat('=', 1, right)];
    disp(line);
end
