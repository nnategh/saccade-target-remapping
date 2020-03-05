function main01(folder)

    if nargin < 1
        folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns/';
        % folder = './data';
    end
    
    global width height tmin tmax
    width = 9;
    height = 9;
    tmin = -540;
    tmax = 540;
    
    tlim = [-500, -200, 0, 100, 200, 500];
    fix1 = tlim(1):tlim(2); % fixation 1 (presacadic) times
    sac  = tlim(3):tlim(4); % saccadic times
    fix2 = tlim(5):tlim(6); % fixation 2 (postsacadic) times

    fix1 = fix1 - tmin + 1; % time -> index
    sac  = sac  - tmin + 1; % time -> index
    fix2 = fix2 - tmin + 1; % time -> index

    filenames = getFilenamesWithSameGrid(folder); % neurons

    W = getW(filenames); % linear kernels: number[neuron, location, time]
    
    fix1W = mean(W(:, :, fix1), 3); % average sensitivity at `fix1`
    sacW  = mean(W(:, :,  sac), 3); % average sensitivity at `sac`
    fix2W = mean(W(:, :, fix2), 3); % average sensitivity at `fix2`

    T = size(W, 3); % number of times
    
    % correlation between ...
    fix1corr = zeros(1, T); % `fix1` and time `t`
    saccorr  = zeros(1, T); % `sac`  and time `t`
    fix2corr = zeros(1, T); % `fix2` and time `t`
    
    fprintf('\nCorrelations: ');
    tic();
    for t = 1:T % for each time `t`
        fix1corr(t) = corr2(fix1W, W(:, :, t));
        saccorr(t)  = corr2(sacW,  W(:, :, t));
        fix2corr(t) = corr2(fix2W, W(:, :, t));
    end
    toc();

    save('main.mat', 'W', 'fix1corr', 'saccorr', 'fix2corr');
    
    % plot
    times = tmin:tmax;
    lineWidth = 4;

    createFigure('Location Sensitivity');
    hold('on');
    window = 101;
    plot(times, gsmooth(fix1corr, window), 'DisplayName', 'fix1', 'LineWidth', lineWidth);
    plot(times, gsmooth(saccorr,  window), 'DisplayName', 'sac', 'LineWidth', lineWidth); 
    plot(times, gsmooth(fix2corr, window), 'DisplayName', 'fix2', 'LineWidth', lineWidth); 
    % plot(times, gsmooth(fix1corr{i} + fix2corr{i}, width), 'DisplayName', 'RF + FF', 'LineWidth', lineWidth, 'LineStyle', '--'); 

    xlabel('time from saccade onset (ms)');
    xticks(unique([tmin, tlim, tmax]));
    xlim([tmin, tmax]);

    ylabel('correlation (unit)');
    yticks(-1:0.5:1)
    ylim([-2, 2]);

    grid('on');
    box('on');

    legend();

    set(gca, 'FontSize', 18);
    
    savefig('main.fig');
end

function W = getW(filenames)
    global width height tmin tmax
    
    n = numel(filenames);
    W = zeros(n, width * height, tmax - tmin + 1);
    
    fprintf('\nLinear kernels: \n');
    tic();
    for i = 1:n
        filename = filenames{i};
        
        [~, name, ~] = fileparts(filename);
        fprintf('%3d - %s\n', i, name);
        
        load(filename, 'skrn');
    
        w = squeeze(skrn(1, :, :, :, :));
        % W = squeeze(mean(skrn, 1));

        w = reshape(w, size(w, 1) * size(w, 2), size(w, 3), size(w, 4)); % location -> index
        w = mean(w, 3); % mean over `delay` dimension
        
        W(i, :, :) = w;
    end
    toc();
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
