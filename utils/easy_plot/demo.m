x1 = linspace(0, 10, 100);  % x data
x2 = linspace(0, 10, 200);  % x data
y1 = sin(x1);  % First curve (sin)
y2 = cos(x2);  % Second curve (cos)

% Plot the curves with automatic styles and show the figure
easy_plot({x1,x2}, {y1, y2}, 'Title', 'Sine and Cosine Waves', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'});


x = linspace(0, 10, 100);  % x data
y1 = sin(x);  % First curve (sin)
y2 = cos(x);  % Second curve (cos)

% Plot with custom line width and save as PNG
easy_plot(x, {y1, y2}, 'LineWidth', 2, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'}, ...
    'SaveAs', 'trig_plot.png');


x = linspace(0, 10, 100);  % x data
y1 = sin(x);  % First curve (sin)
y2 = cos(x);  % Second curve (cos)

% Hide the figure and save as PDF
easy_plot(x, {y1, y2}, 'ShowFigure', false, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'}, ...
    'SaveAs', 'trig_plot.pdf');


x = linspace(0, 10, 100);  % x data
y1 = sin(x);  % First curve (sin)
y2 = cos(x);  % Second curve (cos)
y3 = tan(x);  % Third curve (tan)

% Customize line styles, markers, and save as EPS
easy_plot(x, {y1, y2, y3}, 'LineWidth', 2, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)', 'tan(x)'}, ...
    'SaveAs', 'trig_plot.eps');
