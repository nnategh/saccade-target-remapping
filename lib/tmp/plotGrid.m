function plotGrid()
    W = 9;
    H = 9;
    w = 0.5;
    h = 0.5;
    
    lineWidth = 4;
    fontSize = 34;
    faceColor = [1, 1, 1];
    textColor = [0, 0, 0];
    
    G = reshape(1:81, W, H); % grid
    
    createFigure('Grid');
    
    for i = 1:W
        for j = 1:H
            % square
            rectangle(...
                'Position', [i -  w / 2, j - h / 2, w, h], ...
                'LineWidth', lineWidth, ...
                'FaceColor', faceColor);
            
            % text
            text(i, j, sprintf('%d', G(i, j)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', fontSize, ...
                'Color', textColor);
        end
    end
    
    title('Probe Locations');
    xlabel('x (probe)');
    ylabel('y (probe)');
    
    grid('on');
    box('on');
    axis('square');
    
    axis([0, W + 1, 0, H + 1]);
    xticks(1:W);
    yticks(1:W);
    
    set(gca, 'FontSize', fontSize);
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
