function analyzeRF(rfind)
    % Analyze `receptive field`
    %
    % Parameters
    % ----------
    % - rfind: 1 | 2
    %   Receptive field index
    
    if nargin < 1
        rfind = 1;
    end
    
    RF = getRF(rfind);
    fprintf('RF%d Locations:\n', rfind);
    disp(RF);
    
    gridRF(rfind, RF);
    surfRF(rfind, RF);
    histRF(rfind, RF);
end

% Functions
function gridRF(rfind, RF)
    
    info = getInfo();
    W = info.width;
    H = info.height;
    
    w = 0.5;
    h = 0.5;
    
    lineWidth = info.plotting.lineWidth;
    fontSize = info.plotting.fontSize;
    
    G = zeros(W, H); % grid
    for i = 1:size(RF, 1)
        rf = RF(i, :);
        G(rf(1), rf(2)) = G(rf(1), rf(2)) + 1;
    end
    
    C = G ./ sum(G(:)); % color
            
    
    createFigure('Grid');
    title(sprintf('RF%d', rfind));
    
    for i = 1:W
        for j = 1:H
            % square
            rectangle(...
                'Position', [i -  w / 2, j - h / 2, w, h], ...
                'LineWidth', lineWidth, ...
                'FaceColor', [C(i, j), 0, 0]);
            
            % text
            textColor = [1, 1, 1];
            if G(i, j) == 0
                textColor = [0, 0, 0];
            end
            text(i, j, sprintf('%d', G(i, j)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', fontSize, ...
                'Color', textColor);
        end
    end
    
    grid('on');
    box('on');
    
    axis([0, W + 1, 0, H + 1]);
    axis('square');
    axis('equal');
    xticks(1:W);
    yticks(1:W);
    
    set(gca, 'FontSize', fontSize);
end

function surfRF(rfind, RF)
    
    info = getInfo();
    W = info.width;
    H = info.height;
    fontSize = info.plotting.fontSize;
    
    
    G = zeros(W, H); % grid
    for i = 1:size(RF, 1)
        rf = RF(i, :);
        G(rf(1), rf(2)) = G(rf(1), rf(2)) + 1;
    end
    
    createFigure('Grid');
    
    surf(G');
    axis('equal');
    title(sprintf('RF%d', rfind));
    shading('interp');
    view([0, 90]);
    
    xticks(1:W);
    yticks(1:W);
    
    set(gca, 'FontSize', fontSize);
end

function histRF(rfind, RF)
    % histogram
    createFigure('Receptive Filed');
    rows = 1;
    cols = 2;
    
    info = getInfo();
    fontSize = info.plotting.fontSize;
    
    % - x-coordinate
    subplot(rows, cols, 1);
    histogramXY(RF(:, 1));
    title(sprintf('X-coordinate of RF%d (probe)', rfind));
    
    % - ycoordinate
    subplot(rows, cols, 2);
    histogramXY(RF(:, 2));
    title(sprintf('Y-coordinate of RF%d (probe)', rfind));
    
    % Local functions
    function histogramXY(V)
        histogram(categorical(V), categorical(1:9), 'Normalization', 'probability');
        set(gca, ...
            'FontSize', fontSize, ...
            'YGrid', 'on');
        yticks(0:0.2:1);
        ylim([0, 1]);
    end
end
