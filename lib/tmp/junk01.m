close('all');
clear();
clc();

% folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns/';
folder = './data';

listing = dir(fullfile(folder, '*.mat'));
n = numel(listing);
n = 1;

for i = 1:n
    filename = fullfile(listing(i).folder, listing(i).name);
    
    plotGrid(filename);
end

function plotGrid(filename)
    [x, y, sv, rf, ff] = getLocations(filename);

    createFigure('Grid');
    [W, H] = size(x);
    w = 1;
    h = 1;
    for i = 1:W
        for j = 1:H
            % square
            rectangle('Position', [x(i, j) -  w / 2, y(i, j) - h / 2, w, h])
            % text
            text(x(i, j), y(i, j), sprintf('(%d, %d)', i, j), ...
                'HorizontalAlignment', 'center');
        end
    end
    
    % saccade
    % - start
    rectangle(...
        'Position', [0 -  w / 4, 0 - h / 4, w / 2, h / 2], ...
        'Curvature', [1, 1], ...
        'EdgeColor', [1, 0, 0], ...
        'LineWidth', 4);
    % - stop
    rectangle(...
        'Position', [sv(1) -  w / 4, sv(2) - h / 4, w / 2, h / 2], ...
        'Curvature', [1, 1], ...
        'EdgeColor', [1, 0, 0], ...
        'LineWidth', 4);
    % - arrow
    % annotation('arrow', [0, st(1)], [0, st(2)], 'Units', 'points');
    hold('on');
    quiver(0, 0, sv(1), sv(2), 0, ...
        'LineWidth', 4, ...
        'Color', [0, 0, 0]);
    hold('off');
    
    % rf
    rectangle(...
        'Position', [rf(1) -  w / 2, rf(2) - h / 2, w, h], ...
        'EdgeColor', [1, 0, 0], ...
        'LineWidth', 4);
    
    % ff
    rectangle(...
        'Position', [ff(1) -  w / 2, ff(2) - h / 2, w, h], ...
        'EdgeColor', [0, 0, 1], ...
        'LineWidth', 4);
    
    box('on');
%     grid('on');
    
    title(getNeuronName(filename), 'Interpreter', 'none');
    xlabel('x (dva)');
    ylabel('y (dva)');
%     axis('equal');

    axis([-30, 30, -30, 30]);
    set(gca, 'FontSize', 18);
    
end

function [x, y, sv, rf, ff] = getLocations(filename, N)
    % Get locations
    %
    % Parameters
    % ----------
    % - filename: string
    %   Neuron filename
    % - N: number
    %   Round to N number of digits
    %
    % Returns
    % -------
    % - x: number[, ]
    %   X-coordinate of probe locations in dva
    % - y: number[, ]
    %   Y-coordinate of probe locations in dva
    % - sv: number[2]
    %   Saccade vector in dva
    % - rf: number[2]
    %   Receptive filed in dva
    % - ff: number[2]
    %   Future field in dva
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'XoB', 'YoB', 'st_in_dva', 'rf1_in_probes', 'rf2_in_probes');
    
    x = XoB;
    y = YoB;
    
    sv = st_in_dva;
    
    rf = rf1_in_probes;
    rf = [x(rf(1), rf(2)), y(rf(1), rf(2))];
    
    ff = rf2_in_probes;
    ff = [x(ff(1), ff(2)), y(ff(1), ff(2))];
    
    
    x = round(x, N);
    y = round(y, N);
    sv = round(sv, N);
    rf = round(rf, N);
    ff = round(ff, N);
end

function neuronName = getNeuronName(filename)
    [~, neuronName, ~] = fileparts(filename);
%     neuronName = strrep(neuronName, '_', '-');
end

function h = createFigure(name)
    % Create `full screen` figure
    %
    % Parameters
    % ----------
    % - name: string
    %   Name of figure
    %
    % Return
    % - h: matlab.ui.Figure
    %   Handle of created figure
    
    h = figure(...
        'Name', name, ...
        'Color', 'white', ...
        'NumberTitle', 'off', ...
        'Units', 'normalized', ...
        'OuterPosition', [0, 0, 1, 1] ...
    );
end

