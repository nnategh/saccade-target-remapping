function analyzeSTEffectPropagation()
    % Distribution (propagation) of saccadic effects (specifically saccade
    % target remapping)
    
    global fix sac loc flag
    
    fix = -500:-100; % fixation period
    sac = -10:10; % saccadic period
    loc = getFixationPoint(2); % center location
    
    flag = struct(...
        'EffectSizeMethod', 'pvalue', ... % 'pvalue' | 'tstat' | 'resp'
        'EffectSizeThreshold', 0, ...
        'NumOfEffectSizeThresholds', 10, ...
        'EffectSizeModel', '4', ... % '1' | '2' | '3' | '4'
        'EffectSizePerformance', 'corr'); % 'corr' | 
    
    effectSizeMethods = {'pvalue', 'tstat', 'resp'};
    effectSizeModels = {'1', '2', '3', '4'};
    
    for imeth = 1:numel(effectSizeMethods)
        flag.EffectSizeMethod = effectSizeMethods{imeth};
        
        for imdl = 1:numel(effectSizeModels)
            flag.EffectSizeModel = effectSizeModels{imdl};
            
            try
                plotEffectSizeDist();
                findOptimalEffectSizeThreshold();
                plotControlEffectSizeModel();
            catch
                warning(flag.EffectSizeMethod);
                warning(flag.EffectSizeModel);
            end
            
            close('all');
        end
    end
    
end

% Effect - Size
function S = getEffectSize()
    % Get effect size (quantitative measure of the magnitude of a phenomenon)
    
    global flag
    
    switch flag.EffectSizeMethod
        case 'pvalue'
            S = getEffectSizePValue();
        case 'tstat'
            S = getEffectSizeTStat();
        case 'resp'
            S = getEffectSizeResp();
    end
end

function S = getEffectSizePValue()
    % Get effect size with method -log10(p-value)
    
    global fix sac
    
    fixIdx = msToIndex(fix);
    sacIdx = msToIndex(sac);
    
    S = getOutputField('neda02_S_pvalue');
    
    if ~isempty(S)
        return
    end
    
    W = getW();
    [nn, ~, ~] = size(W); % number of neurons, probe locations, and times
    
    S = zeros(nn, 1); % hypothesis test result/p-value of difference between fixation and saccadic period
    FP2 = getFP(2, true); % probe location of second fixation points
    
    fprintf('\nFind effect size (pvalue):\n');
    tic();
    for in = 1:nn % for each neuron
        % fprintf('Neuron: %d\n', in);
        
        locs = getEffectLocs(FP2(in, :)); % effect locations
        
        % for il = 1:nl % for each probe location
        for il = locs % for each effect probe location
            [~, p] = ttest2(...
                W(in, il, fixIdx), ...
                W(in, il, sacIdx), ...
                'Vartype','unequal');
            
            S(in) = S(in) + -log10(p);
        end
        
        nl = numel(locs); % number of effect locations
        S(in) = S(in) / nl; % averagen on effect locations
    end
    
    toc();
    
    setOutputField('neda02_S_pvalue', S);
end

function S = getEffectSizeTStat()
    % Get effect size (quantitative measure of the magnitude of a phenomenon)
    
    global fix sac
    
    fixIdx = msToIndex(fix);
    sacIdx = msToIndex(sac);
    
    S = getOutputField('neda02_S_tstat');
    
    if ~isempty(S)
        return
    end
    
    W = getW();
    [nn, ~, ~] = size(W); % number of times, probe locations, and times
    
    S = zeros(nn, 1); % hypothesis test result of difference between fixation and saccadic period
    FP2 = getFP(2, true); % probe location of second fixation points
    
    fprintf('\nFind effect size (pvalue):\n');
    tic();
    for in = 1:nn % for each neuron
        % fprintf('Neuron: %d\n', in);
        
        locs = getEffectLocs(FP2(in, :)); % effect locations
        
        % for il = 1:nl % for each probe location
        for il = locs % for each effect probe location
            [~, ~, ~, stats] = ttest2(...
                W(in, il, fixIdx), ...
                W(in, il, sacIdx), ...
                'Vartype','unequal');
            
            S(in) = S(in) + stats.tstat;
        end
        
        nl = numel(locs); % number of effect locations
        S(in) = S(in) / nl; % averagen on effect locations
    end
    
    toc();
    
    setOutputField('neda02_S_tstat', S);
end

function S = getEffectSizeResp()
    % Get effect size (quantitative measure of the magnitude of a phenomenon)
    
    global fix sac
    
    fixIdx = msToIndex(fix);
    sacIdx = msToIndex(sac);
    
    S = getOutputField('neda02_S_resp');
    
    if ~isempty(S)
        return
    end
    
    W = getW();
    [nn, ~, ~] = size(W); % number of times, probe locations, and times
    
    S = zeros(nn, 1); % hypothesis test result of difference between fixation and saccadic period
    FP2 = getFP(2, true); % probe location of second fixation points
    
    fprintf('\nFind effect size (pvalue):\n');
    tic();
    for in = 1:nn % for each neuron
        % fprintf('Neuron: %d\n', in);
        
        locs = getEffectLocs(FP2(in, :)); % effect locations
        
        % for il = 1:nl % for each probe location
        for il = locs % for each effect probe location
            r1 = mean(W(in, il, fixIdx));
            r2 = mean(W(in, il, sacIdx));
            
            S(in) = S(in) + ((r2 - r1) / (r2 + r1));
        end
        
        nl = numel(locs); % number of effect locations
        S(in) = S(in) / nl; % averagen on effect locations
    end
    
    toc();
    
    setOutputField('neda02_S_resp', S);
end

function map = getEffectSizeDist()
    % Get effect size distribution
    
    info = getInfo();
    width = info.width; % width of map
    height = info.height; % height of map
    
    S = getEffectSize(); % number[neuron]
    RF1 = getRF(1); % number[neuron, 2]
    
    idx = getIdxOfEffectiveNeurons(S);
    S = S(idx);
    RF1 = RF1(idx, :);
    
    n = zeros(width, height); % number of neurons in each probe location
    map = zeros(width, height); % average of effect size in each probe location
    
    for i = 1:numel(S) % for each neuron
        rf1 = RF1(i, :);
        
        map(rf1(1), rf1(2)) = map(rf1(1), rf1(2)) + S(i);
        n(rf1(1), rf1(2)) = n(rf1(1), rf1(2)) + 1;
    end
    
    n(n == 0) = 1;
    map = map ./ n;
end

% Effect - Size Thresholds
function idx = getIdxOfEffectiveNeurons(S)
    
    global flag
    
    % S = getEffectSize(); % number[neuron]
    idx = S >= flag.EffectSizeThreshold;
end

function TH = getEffectSizeThresholds()

    global flag
    
    N = flag.NumOfEffectSizeThresholds;

    y = getEffectSize();
    
    p = linspace(0, 1, N + 1);
    p(end) = [];

    TH = quantile(y, p);    
end

function th = findOptimalEffectSizeThreshold()
    
    global flag
    
    fieldName = sprintf('neda02_th_meth_%s_mdl_%s', flag.EffectSizeMethod, flag.EffectSizeModel);
    
    T = getOutputField(fieldName);
    % T = [];
    
    if isempty(T)
        TH = getEffectSizeThresholds();

        fprintf('\nFind best effect size threshold (%s):\n', flag.EffectSizeMethod);
        tic();
        for i = 1:numel(TH)
            th = TH(i);
            fprintf('\nThreshold: %.2g\n', th);

            flag.EffectSizeThreshold = th;
            
            [R2, mdl] = modelEffectSize();
            
            T(i).th = th;
            T(i).R2 = R2;
            T(i).mdl = mdl;

            close('all');
        end

        setOutputField(fieldName, T);
    end
    
    fprintf('\n-----\n');
    [~, I] = max([T.R2]);
    fprintf('\nThreshold: %d\n', T(I).th);
    disp(T(I).mdl);
    
    toc();
end

% Effect - Locations
function locs = getEffectLocs(c, r)
    % Get interest locations for defining effect
    %
    % Parameters
    % ==========
    % - c: [number, number]
    %   Center
    % - r: number
    %   Radius
    %
    % Returns
    % =======
    % - locs: number[, 2]
    %   Location of neighbours
    
    if nargin < 2
        r = 1;
    end
    
    info = getInfo();
    sz = [info.width, info.height];
    
    locs = [];
    for x = -r:r
        for y = -r:r
            l = c + [x, y];
            
            try
                l = sub2ind(sz, l(1), l(2)); % todo: use `probeToIndex`
                locs(end + 1) = l;
            catch
                continue
            end
        end
    end
end

function LOC_CTRL = getLocationsCtrl()
    LOC_CTRL = {};
    for x = 2:3:8
        for y = 2:3:8
            LOC_CTRL{end + 1} = [x, y];
        end
    end
    
    % LOC_CTRL = {[2, 2]}; % to: must be removed
end

% Effect - Times (saccadic Period)
function T = getSlidingTimePeriods(tstart, tstop, tstep, tsize)
    
    T = {};
    for t = tstart:tstep:(tstop - tsize + 1)
        T{end + 1} = t:(t + tsize - 1);
    end
end

function SAC = getSacPeriods()
    SAC = getSlidingTimePeriods(-30, 100, 21, 21);
    % SAC = getSlidingTimePeriods(-30, -3, 7, 21); % todo: must be removed
end

function SAC_CTRL = getSacPeriodsCtrl()
    SAC_CTRL = getSlidingTimePeriods(-250, 250, 21, 21);
    % SAC_CTRL = getSlidingTimePeriods(-250, -223, 7, 21); % todo: must be removed
end

% Linear Models
function [R2, mdl, y, y_, idx] = modelEffectSize()
    y = getEffectSize();
    idx = getIdxOfEffectiveNeurons(y);
    y = y(idx);
    X = getPredictors();
    X = X(idx, :);
    
    try
        mdl = fitlm(X, y, 'RobustOpts', 'on');
        R2 = mdl.Rsquared.Adjusted;
        y_ = mdl.Fitted;
        disp(mdl);
    catch
        warning('Model failed!');
        mdl = nan;
        R2 = nan;
        y_ = nan(size(y));
    end
end

function X = getPredictors()
    
    global flag

    fieldName = sprintf('neda02_x_mdl_%s', flag.EffectSizeModel);
    
    X = getOutputField(fieldName);
    
    if ~isempty(X)
        return
    end
    
    switch flag.EffectSizeModel
        case '1'
            [theta1, rho1] = getRFToFP(1, 1);

            x1 = rho1;
            x2 = theta1;
            
            X = [x1, x2];
        case '2'
            [~, rho1, rf1fp1] = getRFToFP(1, 1);
            [~, rho2] = getRFToFP(1, 2);

            x1 = rho1;
            x2 = rho2;
            x3 = x1 .^ 2;
            x4 = x2 .^ 2;
            x5 = 1 ./ (x1 + eps);
            x6 = 1 ./ (x2 + eps);
            x7 = x5 .^ 2;
            x8 = x6 .^ 2;
            x9 = (x2 - x1) ./ (x2 + x1);
            x10 = rf1fp1(:, 2);
            
            X = [x1, x2, x3, x4, x5, x6, x7, x8, x9, x10];
        case '3'
            [~, rho1, rf1fp1] = getRFToFP(1, 1);
            [~, rho2] = getRFToFP(1, 2);

            x1 = rho1;
            x2 = rho2;
            x3 = x1 .^ 2;
            x4 = x2 .^ 2;
            x5 = (x2 - x1) ./ (x2 + x1);
            x6 = rf1fp1(:, 2);
            
            X = [x1, x2, x3, x4, x5, x6];
        case '4'
            [~, rho1, rf1fp1] = getRFToFP(1, 1);
            [~, rho2] = getRFToFP(1, 2);

            x1 = (rho2 - rho1) ./ (rho2 + rho1);
            x2 = rf1fp1(:, 2);
            
            X = [x1, x2];
    end
    
    setOutputField(fieldName, X);
end

function [R2, mdl] = modelEffectSizeSimpleAndPlot()
    global flag
    
    rows = 2;
    cols = 1;
    
    rfind = 1;
    fpind = 1;
    
    y = getEffectSize();
    idx = getIdxOfEffectiveNeurons(y);
    y = y(idx);
    
    [theta, rho] = getRFToFP(rfind, fpind);
    theta = theta(idx);
    rho = rho(idx);
    
    createFigure('Describe Effect Distribution');
    ylabelTxt = sprintf('Effect Size - %s (unit)', flag.EffectSizeMethod);
    
    % rho
    subplot(rows, cols, 1);
    scatter(rho, y, 'filled');
    title(sprintf('RF%d to FP%d', rfind, fpind));
    xlabel('Distance (dva)');
    ylabel(ylabelTxt);
    setFontSize();
    
    % linear model (simple linear regression)
    % - rho1
    mdl = fitlm(rho, y, 'RobustOpts', 'on');
    b0 = mdl.Coefficients{1, 1};
    b1 = mdl.Coefficients{2, 1};
    y_ = b0 + b1 * rho;
    
    R2 = mdl.Rsquared.Adjusted;
    fprintf('\nLinear Model ~ rho\n');
    fprintf('b0 = %.2g\n', mdl.Coefficients{1, 1});
    fprintf('b1 = %.2g\n', mdl.Coefficients{2, 1});
    fprintf('R2 = %.2g\n', R2);
    
    hold('on');
    plot(rho, y_, ...
        'Color', [0.85, 0.33, 0.10], ...
        'LineStyle', '-', ...
        'LineWidth', 2);
    
    legend({
        'data'
        sprintf('y = %.2g + %.2g x (R2 = %.2g)', b0, b1, R2)});
    
   % theta
    subplot(rows, cols, 2);
    scatter(rad2deg(theta), y, 'filled');
    xlabel('Angle (deg)');
    ylabel(ylabelTxt);
    setFontSize();
    
    saveas(gcf, sprintf('rf%d_fp%d_%s_%.2g.png', rfind, fpind, flag.EffectSizeMethod, flag.EffectSizeThreshold));
end

% Performance
function [P, Y_, I] = measureEffectSizeModelPerf()

    global flag
    
    % Performance
    switch flag.EffectSizePerformance
        case 'corr'
            % - Correlation
            [P, Y_, I] = measureEffectSizeModelPerfCorr();
    end
end

function [P, Y_, I] = measureEffectSizeModelPerfCorr()

    global sac flag
    
    fieldNameP = sprintf(...
        'neda02_perf_corr_meth_%s_mdl_%s', ...
        flag.EffectSizeMethod, flag.EffectSizeModel);
    P = getOutputField(fieldNameP);
    
    fieldNameY_ = sprintf(...
        'neda02_perf_corr_yhat_meth_%s_mdl_%s', ...
        flag.EffectSizeMethod, flag.EffectSizeModel);
    Y_ = getOutputField(fieldNameY_);
    
    fieldNameI = sprintf(...
        'neda02_perf_corr_idx_meth_%s_mdl_%s', ...
        flag.EffectSizeMethod, flag.EffectSizeModel);
    I = getOutputField(fieldNameI);
    
    if ~isempty(P) && ~isempty(Y_) && ~isempty(I)
        return
    end
    
    SAC = getSacPeriods();
    loc = getFixationPoint(2);
    
    fprintf('\nMeasure Performance of Model (Correlation)\n');
    tic();
    nsac = numel(SAC);
    nth = flag.NumOfEffectSizeThresholds;
    Y_ = cell(nsac, nth);
    for isac = 1:nsac
        fprintf('Saccadic period: %d from %d\n', isac, nsac);
        sac = SAC{isac};
        
        TH = getEffectSizeThresholds();
        
        for ith = 1:nth
            fprintf('\tThreshold: %d from %d\n', ith, nth);
                
            flag.EffectSizeThreshold = TH(ith);
            
            % observed, predicted values
            [~, ~, y, y_, idx] = modelEffectSize();
            
            % correlation
            P(isac, ith) = corr(y, y_, 'Type','Spearman');
            Y_{isac, ith} = y_;
            I{isac, ith} = idx;
        end
    end
    
    setOutputField(fieldNameP, P);
    setOutputField(fieldNameY_, Y_);
    setOutputField(fieldNameI, I);
    setOutputField('neda02_SAC', SAC);
    setOutputField('neda02_LOC', loc);
    
    toc();
end

% Controls
function plotControlEffectSizeModel()
    % Control
    % - time
    plotControlEffectSizeModelTime();
    % - location
    plotControlEffectSizeModelLocation();
end

function C = controlEffectSizeModelTime()

    global sac loc flag
    
    fieldName = sprintf(...
        'neda02_ctrl_sac_meth_%s_mdl_%s', ...
        flag.EffectSizeMethod, flag.EffectSizeModel);
    
    C = getOutputField(fieldName);
    
    if ~isempty(C)
        return
    end
    
    [P, Y_, I] = measureEffectSizeModelPerf();
    loc = getOutputField('neda02_LOC');
    
    SAC_CTRL = getSacPeriodsCtrl();
    
    fprintf('\nControl Time Variable\n');
    tic();
    [nsac, nth] = size(P);
    nsacCtrl = numel(SAC_CTRL);
    
    C = zeros(nsac, nth, nsacCtrl + 1);
    for isacCtrl = 1:nsacCtrl
        fprintf('Saccadic period (control): %d from %d\n', isacCtrl, nsacCtrl);

        % observed values
        sac = SAC_CTRL{isacCtrl};
        y = getEffectSize();

        for isac = 1:nsac
            fprintf('Saccadic period: %d from %d\n', isacCtrl, nsacCtrl);
            
            for ith = 1:nth
                fprintf('\t\tThreshold: %d from %d\n', ith, nth);
                
                % predicted values
                y_ = Y_{isac, ith};
                idx = I{isac, ith};

                % correlation
                C(isac, ith, isacCtrl) = corr(y(idx), y_, 'Type','Spearman');
            end
        end
    end
    
    C(:, :, end) = P;
    
    setOutputField(fieldName, C);
    setOutputField('neda02_SAC_CTRL', SAC_CTRL);
    
    toc();
end

function C = controlEffectSizeModelLocation()

    global sac loc flag
    
    fieldName = sprintf(...
        'neda02_ctrl_loc_meth_%s_mdl_%s', ...
        flag.EffectSizeMethod, flag.EffectSizeModel);
    
    C = getOutputField(fieldName);
    
    if ~isempty(C)
        return
    end
    
    [P, Y_, I] = measureEffectSizeModelPerf();
    SAC = getOutputField('neda02_SAC');
    
    LOC_CTRL = getLocationsCtrl();
    
    fprintf('\nControl Location Variable\n');
    tic();
    [nsac, nth] = size(P);
    nlocCtrl = numel(LOC_CTRL);
    
    C = zeros(nsac, nth, nlocCtrl + 1);
    for isac = 1:nsac
        fprintf('\tSaccadic period: %d from %d\n', isac, nsac);
        
        sac = SAC{isac};
        
        for ilocCtrl = 1:nlocCtrl
            fprintf('Location: %d from %d\n', ilocCtrl, nlocCtrl);

            % observed values
            loc = LOC_CTRL{ilocCtrl};
            
            y = getEffectSize();
            
            for ith = 1:nth
                fprintf('\t\tThreshold: %d from %d\n', ith, nth);
                
                % predicted values
                y_ = Y_{isac, ith};
                idx = I{isac, ith};

                % correlation
                C(isac, ith, ilocCtrl) = corr(y(idx), y_, 'Type','Spearman');
            end
        end
    end
    
    C(:, :, end) = P;
    
    setOutputField(fieldName, C);
    setOutputField('neda02_LOC_CTRL', LOC_CTRL);
    
    toc();
end

function plotControlEffectSizeModelTime()
    
    global flag
    
    C = controlEffectSizeModelTime(); % [sac, th, sac_ctrl]
    SAC = getOutputField('neda02_SAC');
    SAC_CTRL = getOutputField('neda02_SAC_CTRL');
    
    nsac = size(C, 1); % number of saccadic periods
    
    rows = 1;
    cols = nsac;
    
    createFigure(sprintf('Control Times (Saccadic Periods) - Method: %s, Model: %s', ...
        flag.EffectSizeMethod, ...
        flag.EffectSizeModel));
    
    for isac = 1:nsac % for each saccadic period
        map = squeeze(C(isac, :, :)); % [th, sac_ctrl]

        subplot(rows, cols, isac);
        plotThresholdControlMap(map);
        caxis([-1, 1]);
        yticks([]);
        xticks([]);

        % title
        sac = SAC{isac};
        title(sprintf('sac = %d:%d', min(sac), max(sac)));
        
    end
    
    subplot(rows, cols, 1);
    % y-axis
    ylabel('Quantile');
    N = flag.NumOfEffectSizeThresholds;    
    p = linspace(0, 1, N + 1);
    p(end) = [];
    p = 1 - p;
    yticks(1:numel(p));
    yticklabels(convertStringsToChars(string(round(p, 2))));
    
    % x-axis
    xlabel('Time Period (Control)');
    n = numel(SAC_CTRL);
    xTickLbls = cell(1, n);
    for i = 1:n
        sac = SAC_CTRL{i};
        xTickLbls{i} = sprintf('%d:%d', min(sac), max(sac));
    end
    xticks(1:5:n);
    xticklabels(xTickLbls(1:5:n));
    xtickangle(45);
    
    c = colorbar('west');
    c.Label.String = sprintf('corr (unit)');
    c.Ticks = [-1, 0, 1];
    
    name = sprintf(...
        'method_%s_model_%s', ...
        flag.EffectSizeMethod, ...
        flag.EffectSizeModel);
    
    name = fullfile(...
        'neda02', ...
        'control', ...
        'time', ...
        name);
    
    saveFigure(name);
    
    % Local functions
    function plotThresholdControlMap(map)
        imagesc(map);
        set(gca, 'YDir', 'normal');
        axis('tight');
        axis('square');

        colormap('gray');
    end
end

function plotControlEffectSizeModelLocation()
    
    global flag
    
    C = controlEffectSizeModelLocation(); % [sac, th, sac_ctrl]
    SAC = getOutputField('neda02_SAC');
    LOC = getOutputField('neda02_LOC');
    LOC_CTRL = getOutputField('neda02_LOC_CTRL');
    
    nsac = size(C, 1); % number of saccadic periods
    
    rows = 1;
    cols = nsac;
    
    createFigure(sprintf('Control Locations - Method: %s, Model: %s', ...
        flag.EffectSizeMethod, ...
        flag.EffectSizeModel));
    
    for isac = 1:nsac % for each saccadic period
        map = squeeze(C(isac, :, :)); % [th, sac_ctrl]

        subplot(rows, cols, isac);
        plotThresholdControlMap(map);
        caxis([-1, 1]);
        yticks([]);
        xticks([]);

        % title
        sac = SAC{isac};
        title(sprintf('sac = %d:%d', min(sac), max(sac)));
    end
    
    subplot(rows, cols, 1);
    % y-axis
    ylabel('Quantile');
    N = flag.NumOfEffectSizeThresholds;    
    p = linspace(0, 1, N + 1);
    p(end) = [];
    p = 1 - p;
    yticks(1:numel(p));
    yticklabels(convertStringsToChars(string(round(p, 2))));
    
    % x-axis
    xlabel('Locations (Control)');
    n = numel(LOC_CTRL);
    xTickLbls = cell(1, n + 1);
    for i = 1:n
        locCtrl = LOC_CTRL{i};
        xTickLbls{i} = sprintf('%d,%d', locCtrl(1), locCtrl(2));
    end
    xTickLbls{n + 1} = sprintf('%d,%d', LOC(1), LOC(2));
    xticks(1:(n + 1));
    xticklabels(xTickLbls);
    xtickangle(45);
    
    c = colorbar('west');
    c.Label.String = sprintf('corr (unit)');
    c.Ticks = [-1, 0, 1];
    
    name = sprintf(...
        'method_%s_model_%s', ...
        flag.EffectSizeMethod, ...
        flag.EffectSizeModel);
    
    name = fullfile(...
        'neda02', ...
        'control', ...
        'location', ...
        name);
    
    saveFigure(name);
    
    % Local functions
    function plotThresholdControlMap(map)
        imagesc(map);
        set(gca, 'YDir', 'normal');
        axis('tight');
        axis('square');

        colormap('gray');
    end
end

% Plot
function plotEffectSizeDist()
    map = getEffectSizeDist();
    
    createFigure('Spatial Distribution of Saccade Target Remapping Effect');
    plotMap(map');
end

function plotMap(map)

    global flag

%     surf(map);
%     view([0, 90]);
%     shading('interp');
    
    imagesc(map);
    set(gca, 'YDir', 'normal');
    
    axis('tight');
    
    colormap('gray');
    
    c = colorbar();
    c.Label.String = sprintf('Effect Size - %s (unit)', flag.EffectSizeMethod);
    % c.Limits = [0, 1];
    % c.Ticks = [0, 0.5, 1];
    
    setFontSize();
end

