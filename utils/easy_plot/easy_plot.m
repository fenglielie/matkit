function handles = easy_plot(x, y, varargin)
    % EASY_PLOT A flexible plotting function that supports multiple curves.
    %
    % INPUT:
    %   x               - x data, a vector or a cell array of vectors.
    %   y               - y data, a vector or a cell array of vectors (multiple curves).
    %
    %   Optional Key-Value Pairs:
    %   'LineWidth'     - Line width, default is 1.5.
    %   'Title'         - Title of the plot.
    %   'XLabel'        - Label for the x-axis.
    %   'YLabel'        - Label for the y-axis.
    %   'Legend'        - Cell array of legend entries, should match number of curves.
    %   'ShowFigure'    - Whether to display the plot window, boolean, default is true.
    %   'SaveAs'        - Path and filename to save the plot. If empty, the plot is not saved.
    %   'SilentSave'    - Whether to suppress the saving message.
    %
    % OUTPUT:
    %   handles         - Handles to the plot axes.
    %
    % EXAMPLE:
    %   x = linspace(0, 10, 100);
    %   easy_plot(x, {sin(x), cos(x)}, LineWidth=2, Title='Trigonometric Functions', ...
    %       XLabel='x', YLabel='y', Legend={'sin(x)', 'cos(x)'}, ...
    %       SaveAs='trig_plot.png');
    %
    %   x1 = linspace(0, 10, 100);
    %   x2 = linspace(0, 10, 200);
    %   easy_plot({x1, x2}, {sin(x1), cos(x2)}, Title='Sine and Cosine Waves', ...
    %       XLabel='x', YLabel='y', Legend={'sin(x)', 'cos(x)'});

    p = inputParser;
    addRequired(p, 'x'); % x data
    addRequired(p, 'y'); % y data
    addParameter(p, 'LineWidth', 1.5, @(v) isnumeric(v) && isscalar(v) && v > 0); % Line width
    addParameter(p, 'Title', '', @ischar); % Plot title
    addParameter(p, 'XLabel', '', @ischar); % x-axis label
    addParameter(p, 'YLabel', '', @ischar); % y-axis label
    addParameter(p, 'Legend', {}, @(v) iscell(v) && (isempty(v) || all(cellfun(@ischar, v)))); % Legend
    addParameter(p, 'ShowFigure', true, @(v) islogical(v) && isscalar(v)); % Whether to show the plot window
    addParameter(p, 'SaveAs', '', @ischar); % Save the plot as an image file
    addParameter(p, 'SilentSave', false, @(v) islogical(v) && isscalar(v)); % Whether to suppress the saving message
    parse(p, x, y, varargin{:});

    LineWidth = p.Results.LineWidth;
    TitleStr = p.Results.Title;
    XLabelStr = p.Results.XLabel;
    YLabelStr = p.Results.YLabel;
    LegendStr = p.Results.Legend;
    ShowFigure = p.Results.ShowFigure;
    SaveAsFile = p.Results.SaveAs;
    SilentSave = p.Results.SilentSave;

    assert(isnumeric(x) || iscell(x), 'x must be a numeric array or a cell array of numeric arrays.');

    if iscell(x)
        assert(all(cellfun(@isnumeric, x)), 'All elements of x must be numeric arrays.');
    end

    assert(isnumeric(y) || iscell(y), 'y must be a numeric array or a cell array of numeric arrays.');

    if iscell(y)
        assert(all(cellfun(@isnumeric, y)), 'All elements of y must be numeric arrays.');
    end

    % Convert x and y to cell arrays if they are not already
    if ~iscell(y)
        y = {y};
    end

    numCurves = length(y); % Number of curves to plot

    if ~iscell(x)
        % If x is a single array, replicate it for each y
        x = repmat({x}, 1, numCurves);
    end

    % Ensure that each x{i} and y{i} have the same length
    for i = 1:numCurves
        assert(length(x{i}) == length(y{i}), 'Each x{i} and y{i} must have the same length.');
    end

    % Validate legend input
    if ~isempty(LegendStr)
        assert(length(LegendStr) == numCurves, 'Legend entries must match the number of curves.');
    end

    % Create the figure window, show or hide based on the 'ShowFigure' flag
    if ShowFigure
        fig = figure; % Normal figure window
    else
        fig = figure('Visible', 'off'); % Hidden figure window
    end

    hold on;
    handles = gobjects(1, numCurves); % Pre-allocate handles array

    % Automatically assign colors, line styles, and markers
    defaultColors = lines(numCurves);
    lineStyles = {'-', '--', ':', '-.'};
    markers = {'o', 's', 'd', 'p', 'h', '^', 'v', '<', '>'};

    for i = 1:numCurves
        xi = x{i};
        yi = y{i};
        plotColor = defaultColors(i, :); % Assign color
        autoLineStyle = lineStyles{mod(i - 1, length(lineStyles)) + 1}; % Assign line style
        autoMarker = markers{mod(i - 1, length(markers)) + 1}; % Assign marker style

        % Automatically adjust MarkerIndices (marker spacing)
        numMarkers = min(10, length(xi)); % Ensure at least 10 markers
        offset = round((i - 1) * length(xi) / (numCurves + 1)); % Offset each curve's markers
        markerIdx = mod(round(linspace(1, length(xi), numMarkers)) + offset, length(xi)) + 1; % Generate marker indices

        % Plot the curve
        handles(i) = plot(xi, yi, 'LineWidth', LineWidth, ...
            'LineStyle', autoLineStyle, 'Marker', autoMarker, ...
            'MarkerIndices', markerIdx, 'Color', plotColor);
    end

    hold off;

    % Set title and axis labels if provided
    if ~isempty(TitleStr), title(TitleStr); end
    if ~isempty(XLabelStr), xlabel(XLabelStr); end
    if ~isempty(YLabelStr), ylabel(YLabelStr); end

    % Add grid
    grid on;

    % Set legend if provided
    if ~isempty(LegendStr) && length(LegendStr) == numCurves
        legend(LegendStr, 'Location', 'best');
    end

    % Automatically save the plot if 'SaveAs' is specified
    if ~isempty(SaveAsFile)
        [~, ~, ext] = fileparts(SaveAsFile); % Get file extension

        switch lower(ext)
            case '.fig'
                savefig(fig, SaveAsFile); % Save as .fig file
            case {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.bmp'}
                saveas(fig, SaveAsFile); % Save as image file
            case {'.pdf', '.eps', '.svg'}
                print(fig, SaveAsFile, ['-d', ext(2:end)], '-r300'); % Save as vector format
            otherwise
                warning('Unsupported file format: %s', ext); % Warning for unsupported formats
        end

        if ~SilentSave
            fprintf('Figure saved as: %s\n', SaveAsFile);
        end

    end

end
