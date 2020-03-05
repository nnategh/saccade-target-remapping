function main(folder)

    if nargin < 1
        folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns/';
        % folder = './data';
    end
    
    global width height tmin tmax dataFilename
    width = 9;
    height = 9;
    tmin = -540;
    tmax = 540;
    dataFilename = 'main.mat';
    
    tlim = [tmin, tmin + 200, 0, 30, tmax];
    fix = tlim(1):tlim(2); % fixation (presacadic) times
    sac = tlim(3):tlim(4); % saccadic times

    fix = fix - tmin + 1; % time -> index
    sac  = sac  - tmin + 1; % time -> index

    filenames = getFilenames(folder); % get filenames with same grid and saccade vector
    W = getW(filenames); % linear kernels: number[neuron, location, time]
    sv = getSaccadeVector(filenames{1}); % saccade vector (dva)
    s = getScale(filenames{1}); % scale (dva per probe)
    probes = getProbes(dvaToProbe(sv, s)); % probe locations
    idx = probesToIndeces(probes); % one-dimensional probe indeces
    
    fixW = mean(W(:, idx, fix), 3); % average sensitivity at `fix`

    T = size(W, 3); % number of times
    
    fixcorr = zeros(1, T); % correlation between `fix` and time `t`
    
    fprintf('\nCorrelations: ');
    tic();
    % before saccade
    for t = 1:(sac(1) - 1) % for each time `t`
        fixcorr(t) = corr2(fixW, W(:, idx, t));
    end
    % saccade
    dt = sac(end) - sac(1) + 1; % delta time
    for t = sac(1):sac(end) % for each time `t`
        u = dvaToProbe(((t - sac(1)) / dt) * sv, s);
        idx = probesToIndeces(probes +  u);
        fixcorr(t) = corr2(fixW, W(:, idx, t));
    end
    % after saccade
    for t = (sac(end) + 1):T % for each time `t`
        fixcorr(t) = corr2(fixW, W(:, idx, t));
    end
    toc();

    save(dataFilename, 'fixcorr', '-append');
    
    % plot
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

function W = getW(filenames)
    global dataFilename
    
    if exist(dataFilename, 'file')
        info = who('-file', dataFilename);
        if ismember('W', info)
            load(dataFilename, 'W');
            return
        end
    end
    
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
        % w = mean(w, 3); % mean over `delay` dimension
        w = max(w, 3); % mean over `delay` dimension
        
        W(i, :, :) = w;
    end
    
    if exist(dataFilename, 'file')
        save(dataFilename, 'W', '-append');
    else
        save(dataFilename, 'W');
    end
    
    toc();
end

function sv = getSaccadeVector(filename, N)
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
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'st_in_dva');
    
    % saccade vectors
    sv = st_in_dva;
    sv = round(sv, N);
end

function s = getScale(filename, N)
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
end

function probes = getProbes(sv)
    % Get safe probe locations by considering given saccade vector
    global width height
    
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
end

function probe = dvaToProbe(dva, s)
    probe = round(dva ./ s);
end

function idx = probesToIndeces(probes)
    global width height
    
    idx = sub2ind([width, height], probes(:, 1), probes(:, 2));
end
