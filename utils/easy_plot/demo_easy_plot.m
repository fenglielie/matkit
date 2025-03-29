clc;
close all;

% Plot the curves with automatic styles and show the figure
x1 = linspace(0, 10, 100);
x2 = linspace(0, 10, 200);
easy_plot({x1, x2}, {sin(x1), cos(x2)}, 'Title', 'Sine and Cosine Waves', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'});

% Plot with custom line width and save as PNG
x = linspace(0, 10, 100);
easy_plot(x, {sin(x), cos(x)}, 'LineWidth', 2, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'}, ...
    'SaveAs', 'test_plot.png');

% Hide the figure and save as PDF
x = linspace(0, 10, 100);
easy_plot(x, {sin(x), cos(x)}, 'ShowFigure', false, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)'}, ...
    'SaveAs', 'test_plot.pdf');

% Customize line styles, markers, and save as EPS
x = linspace(-pi, pi, 100);
easy_plot(x, {sin(x), cos(x), x}, 'LineWidth', 2, 'Title', 'Trigonometric Functions', ...
    'XLabel', 'x', 'YLabel', 'y', 'Legend', {'sin(x)', 'cos(x)', 'x'}, ...
    'SaveAs', 'test_plot.eps');
