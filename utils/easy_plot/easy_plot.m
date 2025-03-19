function handles = easy_plot(x, varargin)
    % easy_plot - A flexible plotting function that supports multiple curves.
    %
    % Inputs:
    %   x           - x data, can be a vector or a cell array of vectors.
    %   y           - y data, can be a vector or a cell array of vectors (multiple curves).
    %
    %   Optional Key-Value Pairs:
    %   'LineWidth' - Line width, default is 1.5.
    %   'Title'     - Title of the plot.
    %   'XLabel'    - Label for the x-axis.
    %   'YLabel'    - Label for the y-axis.
    %   'Legend'    - Cell array of legend entries, should match number of curves.
    %   'ShowFigure' - Whether to display the plot window, boolean, default is true.
    %   'SaveAs'    - Path and filename to save the plot. If empty, the plot is not saved.
    %   'SilentSave' - Whether to suppress the saving message.

    % Parse the input arguments
    p = inputParser;
    addRequired(p, 'x');  % x data
    addOptional(p, 'y', []);  % y data
    addParameter(p, 'LineWidth', 1.5);  % Line width
    addParameter(p, 'Title', '');  % Plot title
    addParameter(p, 'XLabel', '');  % x-axis label
    addParameter(p, 'YLabel', '');  % y-axis label
    addParameter(p, 'Legend', {});  % Legend
    addParameter(p, 'ShowFigure', true);  % Whether to show the plot window
    addParameter(p, 'SaveAs', '');  % Save the plot as an image file
    addParameter(p, 'SilentSave', false); % Whether to suppress the saving message
    parse(p, x, varargin{:});

    % Extract values from the parsed parameters
    y_data = p.Results.y;
    LineWidth = p.Results.LineWidth;
    TitleStr = p.Results.Title;
    XLabelStr = p.Results.XLabel;
    YLabelStr = p.Results.YLabel;
    LegendStr = p.Results.Legend;
    ShowFigure = p.Results.ShowFigure;
    SaveAsFile = p.Results.SaveAs;
    SilentSave = p.Results.SilentSave;

    % Convert x and y to cell arrays if they are not already
    if ~iscell(y_data)
        y_data = {y_data};
    end
    numCurves = length(y_data);  % Number of curves to plot

    if ~iscell(x)  % If x is a single array, replicate it for each y
        x = repmat({x}, 1, numCurves);
    end

    % Automatically assign colors, line styles, and markers
    defaultColors = lines(numCurves);  % Default MATLAB colors
    lineStyles = {'-', '--', ':', '-.'};  % Line styles
    markers = {'o', 's', 'd', 'p', 'h', '^', 'v', '<', '>'};  % Marker styles

    % Create the figure window, show or hide based on the 'ShowFigure' flag
    if ShowFigure
        fig = figure;  % Normal figure window
    else
        fig = figure('Visible', 'off');  % Hidden figure window
    end
    hold on;
    handles = gobjects(1, numCurves);  % Pre-allocate handles array

    for i = 1:numCurves
        xi = x{i};
        yi = y_data{i};
        plotColor = defaultColors(i, :);  % Assign color
        autoLineStyle = lineStyles{mod(i-1, length(lineStyles)) + 1};  % Assign line style
        autoMarker = markers{mod(i-1, length(markers)) + 1};  % Assign marker style

        % Automatically adjust MarkerIndices (marker spacing)
        numMarkers = min(10, length(xi));  % Ensure at least 10 markers
        offset = round((i-1) * length(xi) / (numCurves + 1));  % Offset each curve's markers
        markerIdx = mod(round(linspace(1, length(xi), numMarkers)) + offset, length(xi)) + 1;  % Generate marker indices

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
        [~, ~, ext] = fileparts(SaveAsFile);  % Get file extension
        switch lower(ext)
            case '.fig'
                savefig(fig, SaveAsFile);  % Save as .fig file
            case {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.bmp'}
                saveas(fig, SaveAsFile);  % Save as image file
            case {'.pdf', '.eps', '.svg'}
                print(fig, SaveAsFile, ['-d', ext(2:end)], '-r300');  % Save as vector format
            otherwise
                warning('Unsupported file format: %s', ext);  % Warning for unsupported formats
        end

        if ~SilentSave
            fprintf('Figure saved as: %s\n', SaveAsFile);
        end
    end
end
