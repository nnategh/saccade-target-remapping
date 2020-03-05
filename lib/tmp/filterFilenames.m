function filenames = filterFilenamesBySaccadeDirection(filenames)
    % Analyze motion vectors (fix1 -> fix2 | rf1 -> rf2)
    %
    % Parameters
    % ----------
    % - flag: 'fix' | 'rf'
    %   Select motion vector

    if nargin < 1
        flag = 'rf';
    end
    
    if nargin < 2
        folder = getDataFolder();
    end

    filenames = getFilenames(folder);

    [V, O, x, y] = getMotionVectors(flag, filenames);

    idx = histogramMotionVectors(V);
    
    V = V(idx, :);
    O = O(idx, :);
    
    gridMotionVectors(V, O, x, y);
    
    filenames = filenames(idx);
end

% Functions
function [V, O, x, y] = getMotionVectors(flag, filenames, N)
    % Get motion vectors (fix1 -> fix2 | rf1 -> rf2)
    %
    % Parameters
    % ----------
    % - flag: 'fix' | 'rf'
    %   Select motion vector
    % - filename: string
    %   Neuron filename
    % - N: number
    %   Round to N number of digits
    %
    % Returns
    % -------
    % - V: number[, 2]
    %   Motion vectors
    % - O: number[, 2]
    %   Start points
    % - x: number[, ]
    %   X-coordinate of probe locations (dva)
    % - y: number[, ]
    %   Y-coordinate of probe locations (dva)
    
    if nargin < 3
        N = 3;
    end
    
    n = numel(filenames); % number of neurons
    SV = zeros(n, 2); % saccade vectors
    RF = zeros(n, 2); % receptive filed
    FF = zeros(n, 2); % future field

    fprintf('\n Motion Vectors: ');
    tic();
    for i = 1:n
        filename = filenames{i};
        
        load(filename, 'XoB', 'YoB', 'st_in_dva', 'rf1_in_probes', 'rf2_in_probes');
    
        % saccade vectors
        sv = round(st_in_dva, N);
        SV(i, :) = sv;
        
        % field vectors
        x = round(XoB, N);
        y = round(YoB, N);
        
        rf = rf1_in_probes;
        rf = [x(rf(1), rf(2)), y(rf(1), rf(2))];
        RF(i, :) = rf;

        ff = rf2_in_probes;
        ff = [x(ff(1), ff(2)), y(ff(1), ff(2))];
        FF(i, :) = ff;
    end
    
    switch flag
        case 'fix'
            V = SV;
            O = zeors(size(V));
        case 'rf'
            V = FF - RF;
            O = RF;
    end
    
    toc();
end

function idx = histogramMotionVectors(V)
    % Histogram of motion vectors
    %
    % Parameters
    % ----------
    % - V: number[, 2]
    %   Motion vectors
    
    [R, A] = getRadiusAngle(V);
    
    % filter motion vectors
    idx = (A == 180);
    A = A(idx);
    R = R(idx);
    
    disp('Magnitude(dva), Direction(degree)');
    disp([R, A]);
    
    % histogram
    createFigure('Motion Vectors');
    rows = 1;
    cols = 2;
    fontSize = 18;
    
    % - magnitude
    subplot(rows, cols, 1);
    histogramRA(R);
    title('Magnitude of motion vector (dva)');
    % - direction
    subplot(rows, cols, 2);
    histogramRA(A);
    title('Direction of motion vector (degree)');
    
    % Local functions
    function histogramRA(X)
        histogram(categorical(X), 'Normalization', 'probability');
        % histogram(X, 'Normalization', 'probability');
        set(gca, ...
            'FontSize', fontSize, ...
            'YGrid', 'on');
        yticks(0:0.2:1);
        ylim([0, 1]);
    end
end

function [R, A] = getRadiusAngle(V)
    % Get radius/angles
    
    n = size(V, 1);
    R = zeros(n, 1);
    A = zeros(n, 1);
    
    for i = 1:n
        v = V(i, :);
        R(i) = norm(v);
        A(i) = atan2d(v(2), v(1));
    end
end

function gridMotionVectors(V, O, x, y)
    
    createFigure('Grid of Motion Vectors');
    
    % grid
    W = 9;
    H = 9;
    w = 0.1;
    h = 0.1;
    for i = 1:W
        for j = 1:H
            % square
            rectangle('Position', [x(i, j) -  w / 2, y(i, j) - h / 2, w, h])
        end
    end
    
    % vectors
    lineWidth = 2;
    hold('on');
    n = size(V, 1);
    for i = 1:n
        o = O(i, :);
        v = V(i, :);
        
        quiver(o(1), o(2), v(1), v(2), 0, ...
            'LineWidth', lineWidth, ...
            'Color', [0, 0, 0]);
    end
    hold('off');
    
    box('on');
    
    title('Motion Vectors');
    xlabel('x (dva)');
    ylabel('y (dva)');

    % axis([-30, 30, -30, 30]);
    set(gca, 'FontSize', 18);
    
end
