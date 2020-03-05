function neda01()
    % Plot responsive locations
    % Responsive location: A location which a neuron significantly is
    % responsive to
    
    global alpha fix sac
    
    alpha = 1e-10; % significance level of the hypothesis test
    fix = -500:-100; % time indeces for fixation period
    sac = -10:10; % time indeces for saccadic period
    
    % findBestParams();
    % previewResponsiveLocationsSingleNeuron();
        
    % plotResponsiveLocationsAllNeurons();
    % plotResponsiveLocationsSingleNeuron(1)
end

% Data
function findBestParams()
    % Find best parameters for `alpha`, `fix`, and `sac`
    
    global alpha fix sac
    
    ALPHA = {1e-1, 1e-2, 1e-5, 1e-10, 1e-15, 1e-20}; % 1e-10
    FIX = {-500:-400, -500:-100, -200:-100}; % -500:-100
    SAC = {-10:10, -10:50, 0:50, 0:100}; % -10:10
    
    fprintf('\nFind best parameters for `alpha`, `fix`, and `sac`:\n');
    mainTimer = tic();
    for ialpha = 1:numel(ALPHA)
        for ifix = 1:numel(FIX)
            for isac = 1:numel(SAC)
                alpha = ALPHA{ialpha};
                fix = FIX{ifix};
                sac = SAC{isac};
                
                plotResponsiveLocationsAllNeurons();
                
                close('all');
            end
        end
    end
    toc(mainTimer);
end

function H = getHypothesisTestResult()
    % Get hypothesis test result for a specific significance level and responsive locations
    
    global alpha fix sac
    
    fixIdx = msToIndex(fix);
    sacIdx = msToIndex(sac);
    
    H = getOutputField('neda01_H');
    % H = [];
    
    if ~isempty(H)
        return
    end
    
    W = getW();
    
    [nn, nl, ~] = size(W); % number of times, probe locations, and times
    
    H = zeros(nn, nl); % hypothesis test result of difference between fixation and saccadic period
    
    fprintf('\nFind responsive locations:\n');
    tic();
    for in = 1:nn % for each neuron
        fprintf('Neuron: %d\n', in);
        
        for il = 1:nl % for each probe location
            [h, ~] = ttest2(...
                W(in, il, fixIdx), ...
                W(in, il, sacIdx), ...
                'Alpha', alpha, ...
                'Vartype','unequal');
            
            % P(in, ip) = 1 - p;
            % P(in, il) = 1 / (p + eps);
            
            H(in, il) = h;
        end
    end
    toc();
    
    setOutputField('neda01_H', H);
end

% Plot
function plotResponsiveLocationsSingleNeuron(neuronInd)
    % Plot responsive locations for a given neuron
    
    % plot
    [width, height] = getWidthHeightOfGrid();
    
    H = getHypothesisTestResult();
    map = reshape(H(neuronInd, :), width, height);
    
    titleTxt = sprintf('Responsive Locations - Neront #%d', neuronInd);
    createFigure(titleTxt);
    plotImage(map');
    
    title(titleTxt);
    xlabel('x (probe)');
    ylabel('y (probe)');
    
    % fixation points
    plotFixationPoint(1);
    plotFixationPoint(2);
    
    % receptive field 1
    plotReceptiveField(1, neuronInd);
    
    % save figure
    [~, name] = fileparts(getFigureName());
    name = sprintf('%s_neuron_%d', name, neuronInd);
    name = fullfile(...
        'neda01', ...
        'responsive-locations', ...
        'one', ...
        name);
    saveFigure(name);
end

function plotResponsiveLocationsAllNeurons()
    % Plot responsive locations for all neurons
    
    [width, height] = getWidthHeightOfGrid();
    
    rows = 1;
    cols = 2;
    
    P = getHypothesisTestResult();
    
    createFigure('Responsive Locations');
    
    % all neurons
    subplot(rows, cols, 1);
    plotImage(P);
    xlabel('Locations (probe)');
    ylabel('Neuron (#)');
    
    % mean on neurons
    subplot(rows, cols, 2);
    map = mean(P, 1);
    map = reshape(map, width, height);
    plotImage(map');
    xlabel('x (probe)');
    ylabel('y (probe)');
    
    % fixation points
    plotFixationPoint(1);
    plotFixationPoint(2);
    
    name = fullfile(...
        'neda01', ...
        'responsive-locations', ...
        'all', ...
        getFigureName());
    saveFigure(name);
end

function plotFixationPoint(ind)
    % Plot fixation point probe location

    info = getInfo();
    fontSize = info.plotting.fontSize;
    
    fp = getFixationPoint(ind);

    % square
%     rectangle(...
%         'Position', [fp(1), fp(2), 1, 1], ...
%         'LineWidth', 1, ...
%         'FaceColor', [1, 0, 0]);

    % text
    text(fp(1), fp(2), sprintf('FP%d', ind), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', fontSize, ...
        'Color', [1, 0, 0]);
end

function plotReceptiveField(rfInd, neuronInd)
    % Plot receptive field probe location

    info = getInfo();
    fontSize = info.plotting.fontSize;
    
    rf = getReceptiveField(rfInd);
    rf = rf(neuronInd, :);

    % square
%     rectangle(...
%         'Position', [fp(1), fp(2), 1, 1], ...
%         'LineWidth', 1, ...
%         'FaceColor', [1, 0, 0]);

    % text
    text(rf(1), rf(2), sprintf('RF%d', rfInd), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', fontSize, ...
        'Color', [1, 0, 0]);
end

function histResponsiveLocationsAllNeurons()
    P = getHypothesisTestResult();
    
    createFigure('Histogram of Responsive Locations - All Neurons');
    histogram(log(P(:)));
    
    disp('End');
end

function previewResponsiveLocationsSingleNeuron()
    
    H = getHypothesisTestResult();

    for neuronInd = 1:size(H, 1)
        fprintf('Neuron: %d\n', neuronInd);
        
        plotResponsiveLocationsSingleNeuron(neuronInd);
        
        close('all');
    end
end

% Helper methods
function plotSurf(map)
    surf(map);
    view([0, 90]);
    shading('interp');
    
    axis('tight');
    
    c = colorbar();
    c.Label.String = '1 - p-value (unit)';
    % c.Limits = [0, 1];
    % c.Ticks = [0, 0.5, 1];
    
    setFontSize();
end

function plotImage(map)

    global alpha
    
    imagesc(map);
    set(gca, 'YDir', 'normal');
    
    axis('tight');
    
    colormap('gray');
    
    c = colorbar();
    c.Label.String = sprintf('Hypothesis test result (significance level %g)', alpha);
    c.Limits = [0, 1];
    c.Ticks = [0, 0.5, 1];
    
    setFontSize();
end

function figureName = getFigureName()
    global alpha fix sac
    
    figureName = sprintf(...
        'alpha_%g_fix_%g_%g_sac_%g_%g', ...
        alpha, fix(1), fix(end), sac(1), sac(end));
end

