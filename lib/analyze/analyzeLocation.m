function analyzeLocation(dataFolder)

    if nargin < 1
        dataFolder = getDataFolder();
    end
    
    % info
    % todo: save `info` to `ouput.mat`
    load('info.mat', 'width', 'height', 'tmin', 'tmax');
    
    tlim = [tmin, tmin + 200, 0, 30, tmax]; % time limits
    fix = tlim(1):tlim(2); % fixation (presacadic) times
    sac = tlim(3):tlim(4); % saccadic times

    fix = fix - tmin + 1; % time -> index
    sac = sac  - tmin + 1; % time -> index

    filenames = getFilenames(dataFolder); % get filenames with same grid and saccade vector
    W = getW(filenames); % linear kernels: number[neuron, location, time]
    sv = getSacVector(filenames{1}); % saccade vector (dva)
    s = getProbeToDVAScale(filenames{1}); % scale (dva per probe)
    [probes, width_, height_] = getProbes(dvaToProbe(sv, s), width, height); % probe locations
    idx = probesToIndeces(probes, width, height); % one-dimensional probe indeces
    
    fixW = mean(W(:, idx, fix), 3); % average sensitivity at `fix`

    nt = size(W, 3); % number of times
    nl = numel(idx); % number of interest locations
    
    DP = zeros(nt, 9); % displacement for 8-connectivity
    PD = zeros(nt, nl * (nl - 1) / 2); % pairwise distance between probe locations
    
    fixcorr = zeros(1, nt); % correlation between `fix` and time `t`
    
    fprintf('\nCorrelations: ');
    tic();
    % before saccade
    r = 1; % maximum displacement
    for t = 1:(sac(1) - 1) % for each time `t`
        w = W(:, idx, t);
        fixcorr(t) = corr2(fixW, w);
        DP(t, :) = dplace(fixW, w, width_, height_, r);
        PD(t, :) = pdist(w');
    end
    % saccade
    dt = sac(end) - sac(1) + 1; % delta time
    for t = sac(1):sac(end) % for each time `t`
        u = dvaToProbe(((t - sac(1)) / dt) * sv, s);
        idx = probesToIndeces(probes +  u, width, height);
        
        w = W(:, idx, t);
        fixcorr(t) = corr2(fixW, w);
        DP(t, :) = dplace(fixW, w, width_, height_, r);
        PD(t, :) = pdist(w');
    end
    % after saccade
    for t = (sac(end) + 1):nt % for each time `t`
        w = W(:, idx, t);
        fixcorr(t) = corr2(fixW, w);
        DP(t, :) = dplace(fixW, w, width_, height_, r);
        PD(t, :) = pdist(w');
    end
    toc();

    setOutputField('fixcorr', fixcorr);
    setOutputField('DP', DP);
    setOutputField('PD', PD);
    
    % plot `DP`
    createFigure('Displacement');
    
    c = {};
    for x = -1:1
        for y = -1:1
            c{end + 1} = sprintf('(%d, %d)', x, y);
        end
    end
    bar(categorical(c), mean(DP));
    
    title('Displacement');
    xlabel('(x, y) coordinate (probe)');
    ylabel('correlation (unit)');
    
    yticks(0:0.05:1);
    
    set(gca, ...
        'FontSize', 18, ...
        'YGrid', 'on');
    
    % plot `PD`
    createFigure('Pairwise Distance');
    
    histogram(mean(PD), 'Normalization', 'probability');
    
    title('Pairwise distance between probe locations');
    xlabel('distance (probe)');
    ylabel('probability (unit)');
    
    yticks(0:0.05:1);
    
    set(gca, ...
        'FontSize', 18, ...
        'YGrid', 'on');

    
    % plot `fixcorr`
    times = tmin:tmax;
    lineWidth = 4;

    createFigure('Location Sensitivity');
    hold('on');
    window = 21;
    plot(times, gsmooth(fixcorr, window), 'LineWidth', lineWidth);
    
    title('Correlation between fixation template and each time');
    
    xlabel('time from saccade onset (ms)');
    xticks(unique([tmin, tlim, tmax]));
    xlim([tmin, tmax]);

    ylabel('correlation (unit)');
    yticks(-1:0.5:1)
    ylim([-2, 2]);

    grid('on');
    box('on');

    set(gca, 'FontSize', 18);
    
    savefig('main.fig');
end

function sv = getSacVector(filename, N)
    % Get saccade vector (fp1 -> fp2)
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
    % - sv: number[2]
    %   Saccade vector (fp1 -> fp2);
    
    sv = getOutputField('sv');
    
    if ~isempty(sv)
        return
    end
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'st_in_dva');
    
    % saccade vectors
    sv = st_in_dva;
    sv = round(sv, N);
    
    setOutputField('sv', sv);
end

function s = getProbeToDVAScale(filename, N)
    % Get scale in `x` and `y` directions (dva)
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
    % - s: number[2]
    %   Scale [sx, sy] in dva
    
    s = getOutputField('s');
    
    if ~isempty(s)
        return
    end
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'XoB', 'YoB');
    
    x = XoB;
    y = YoB;
    
    x = round(x, N);
    y = round(y, N);
    
    % scale
    sx = x(2, 1) - x(1, 1);
    sy = y(1, 2) - y(1, 1);
    
    s = [sx, sy];
    
    setOutputField('s', s);
end

function [probes, width_, height_] = getProbes(sv, width, height)
    % Get safe probe locations by considering given saccade vector
    
    dx = sv(1);
    if dx < 0
        xmin = 1 - dx;
        xmax = width;
    else
        xmin = 1;
        xmax = width - dx;
    end
    
    dy = sv(2);
    if dy < 0
        ymin = 1 - dy;
        ymax = height;
    else
        ymin = 1;
        ymax = height - dy;
    end
    
    probes = zeros(0, 2);
    for x = xmin:xmax
        for y = ymin:ymax
            probes(end + 1, :) = [x, y];
        end
    end
    
    width_ = xmax - xmin + 1;
    height_ = ymax - ymin + 1;
end

function probe = dvaToProbe(dva, s)
    probe = round(dva ./ s);
end

function idx = probesToIndeces(probes, width, height)
    idx = sub2ind([width, height], probes(:, 1), probes(:, 2));
end

function dp = dplace(w1, w2, width, height, r)
    idx = getIdx(width, height, r);
    
    n = numel(idx); % number of indeces
    dp = zeros(1, n); % displacements
    i0 = (n + 1) / 2; % index of (0, 0) displacement
    w0 = w2(:, idx{i0});
    for i = 1:n
        dp(i) = corr2(w0, w1(:, idx{i}));
    end
end

function idx = getIdx(w, h, r)
    w_ = w - 2 * r;
    h_ = h - 2 * r;
    
    sz = [w, h];
    r2 = 2 * r + 1;
    idx = {};
    for x = 1:r2
        for y = 1:r2
            idx{end + 1} = [];
            for xx = x:(x + w_ - 1)
                for yy = y:(y + h_ - 1)
                    idx{end}(end + 1) = sub2ind(sz, xx, yy);
                end
            end
        end
    end
end

function dp = dplaceOld(w1, w2)

    w2 = w2(2:end-1, 2:end-1);

    [m1, n1] = size(w1);
    [m2, n2] = size(w2);
    
    m = m1 - m2 + 1;
    n = n1 - n2 + 1;
    
    dp = zeros(1, m * n);
    
    ind = 1;
    for i = 1:m
        for j = 1:n
            dp(ind) = corr2(w1(i:(i + m2 - 1), j:(j + n2 - 1)), w2);
            ind = ind + 1;
        end
    end
    
    % Local functions
    
end