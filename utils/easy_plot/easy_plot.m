function handles = easy_plot(x, y, varargin)
    % EASY_PLOT A flexible plotting function that supports multiple curves.
    %
    % INPUT:
    %   x                   - x data, a vector or a cell array of vectors.
    %   y                   - y data, a vector or a cell array of vectors (multiple curves).
    %
    %   Optional Key-Value Pairs:
    %       'LineWidth'     - Line width, default is 1.5.
    %       'Title'         - Title of the plot.
    %       'XLabel'        - Label for the x-axis.
    %       'YLabel'        - Label for the y-axis.
    %       'Legend'        - Cell array of legend entries, should match number of curves.
    %       'ShowFigure'    - Whether to display the plot window, boolean, default is true.
    %       'SaveAs'        - Path and filename to save the plot. If empty, the plot is not saved.
    %       'SilentSave'    - Whether to suppress the saving message.
    %
    % OUTPUT:
    %   handles             - Handles to the plot axes.
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
    %
    % NOTE:
    %
    %   The following operations can be performed on the handles returned by easy_plot:
    %
    % |      Operation       |                         Code Example                         |
    % | :------------------: | :----------------------------------------------------------: |
    % |     Change Color     |                  `handles(1).Color = 'r';`                   |
    % |   Change LineStyle   |                `handles(1).LineStyle = '--';`                |
    % |   Change LineWidth   |                 `handles(1).LineWidth = 2;`                  |
    % |    Change Marker     |                  `handles(1).Marker = 'o';`                  |
    % | Change MarkerIndices |  `handles(1).MarkerIndices = 1:5:numel(handles(1).XData);`   |
    % |       Get Data       |   `x_data = handles(1).XData; y_data = handles(1).YData;`    |
    % |   Hide/Show Curve    | `handles(1).Visible = 'off';` / `handles(1).Visible = 'on';` |
    % |    Change Legend     |        `handles(1).DisplayName = 'New Name'; legend;`        |
    % |     Delete Curve     |                    `delete(handles(1));`                     |
    % |     Update Data      |    `handles(1).XData = new_x; handles(1).YData = new_y;`     |

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

    numCurves = numel(y); % Number of curves to plot

    if ~iscell(x)
        % If x is a single array, replicate it for each y
        x = repmat({x}, 1, numCurves);
    end

    % Ensure that each x{i} and y{i} have the same size
    for i = 1:numCurves
        assert(isequal(size(x{i}), size(y{i})), 'Each x{i} and y{i} must have the same size.');
    end

    % Validate legend input
    if ~isempty(LegendStr)
        assert(numel(LegendStr) == numCurves, 'Legend entries must match the number of curves.');
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
    colorOrder = get(gca, 'ColorOrder');
    lineStyles = {'-', '--', ':', '-.'};
    markers = {'o', 's', 'd', 'p', 'h', '^', 'v', '<', '>'};

    totalMarkerNum = min(10 * numCurves, 50);
    markerIndices = compute_marker_indices(x, totalMarkerNum);

    for i = 1:numCurves
        xi = x{i};
        yi = y{i};
        plotColor = colorOrder(mod(i - 1, size(colorOrder, 1)) + 1, :); % Assign color
        autoLineStyle = lineStyles{mod(i - 1, numel(lineStyles)) + 1}; % Assign line style
        autoMarker = markers{mod(i - 1, numel(markers)) + 1}; % Assign marker style

        % Plot the curve
        handles(i) = plot(xi, yi, 'LineWidth', LineWidth, ...
            'LineStyle', autoLineStyle, 'Marker', autoMarker, ...
            'MarkerIndices', markerIndices{i}, 'Color', plotColor);
    end

    hold off;
    grid on;

    % Set title and axis labels if provided
    if ~isempty(TitleStr), title(TitleStr); end
    if ~isempty(XLabelStr), xlabel(XLabelStr); end
    if ~isempty(YLabelStr), ylabel(YLabelStr); end

    % Set legend if provided
    if ~isempty(LegendStr) && numel(LegendStr) == numCurves
        legend_handle = legend(LegendStr, 'Location', 'best');
        legend_handle.Box = 'off';
    end

    % Automatically save the plot if 'SaveAs' is specified
    if ~isempty(SaveAsFile)
        [folder, ~, ext] = fileparts(SaveAsFile); % Get file extension

        % Create the parent folder if it doesn't exist
        if ~isempty(folder) && ~isfolder(folder)
            mkdir(folder);

            if ~SilentSave
                fprintf('Parent folder created: %s\n', folder);
            end

        end

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

function markerIndices = compute_marker_indices(x, totalMarkers)
    numCurves = numel(x);

    xmin = inf;
    xmax = -inf;

    for i = 1:numCurves
        xi = x{i};
        xmin = min(xmin, min(xi));
        xmax = max(xmax, max(xi));
    end

    globalMarkers = linspace(xmin, xmax, totalMarkers);

    markerIndices = cell(1, numCurves);

    for i = 1:numCurves
        markerIndices{i} = [];
    end

    for j = 1:totalMarkers
        curveIdx = mod(j - 1, numCurves) + 1;
        xi = x{curveIdx};

        if globalMarkers(j) >= min(xi) && globalMarkers(j) <= max(xi)
            [~, idx] = min(abs(xi - globalMarkers(j)));
            markerIndices{curveIdx}(end + 1) = idx;
        end

    end

    for i = 1:numCurves
        markerIndices{i} = unique(markerIndices{i});
    end

end
