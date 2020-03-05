function DP = getDisplacement()
    % Get displacements
    
    info = getInfo();
    
    switch info.flag.displacement
        case '1pad'
            DP = getDisplacement1();
        case '3x3'
            DP = getDisplacement2();
        case '1x1'
            DP = getDisplacement3();
    end
end

%% 1
function DP = getDisplacement1()
    % Get displacements

    DP = getOutputField('DP');
    % DP = [];
    
    if ~isempty(DP)
        return
    end
    
    W = getW(); % linear kernels: number[neuron, location, time]
    
    % W = changeW(W); % todo: must be removed
    
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    % fixW = getFixW(); % average sensitivity at fixation period
    
    nt = getNumOfTimes(); % number of times
    DP = zeros(nt, 9); % correlation between `fix` and time `t`
    
    [width_, height_] = getWidthHeightOfInterestGrid();
    
    times = getTimes();
    
    fprintf('\nDisplacements: ');
    tic();
    for t = 1:nt
        fprintf('Time: %d\n', times(t));
        
        % DP(t, :) = dplace1(fixW,  W(:, idx{t}, t), width_, height_);
        DP(t, :) = dplace1(W(:, idx{t}, t),  W(:, idx{t}, t), width_, height_);
    end
    toc();

    setOutputField('DP', DP);
end

function dp = dplace1(w1, w2, width, height)
    idx = getIdx1(width, height);
    
    n = numel(idx); % number of indeces
    dp = zeros(1, n); % displacements
    w0 = w2(:, idx{5});% index of (0, 0) displacement
    for i = 1:n
        dp(i) = corr2(w0, w1(:, idx{i}));
    end
end

function idx = getIdx1(w, h)
    w_ = w - 2;
    h_ = h - 2;
    
    sz = [w, h];
    idx = {};
    for x = 1:3
        for y = 1:3
            idx{end + 1} = [];
            for xx = x:(x + w_ - 1)
                for yy = y:(y + h_ - 1)
                    idx{end}(end + 1) = sub2ind(sz, xx, yy);
                end
            end
        end
    end
end

%% 2
function DP = getDisplacement2()
    % Get displacements

    DP = getOutputField('DP');
    % DP = [];
    
    if ~isempty(DP)
        return
    end
    
    W = getW(); % linear kernels: number[neuron, location, time]
    % fixW = getFixW(); % average sensitivity at fixation period
    
    nt = getNumOfTimes(); % number of times
    [width, height] = getWidthHeightOfInterestGrid(); % width and height of target grid
    DP = zeros(nt, width - 4, height - 4, 9); % correlation between `fix` and time `t`
    
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    
    times = getTimes();
    
    fprintf('\nDisplacements:\n');
    tic();
    for t = 1:nt
        fprintf('Time: %d\n', times(t));
        % DP(t, :, :, :) = dplace2(fixW,  W(:, idx{t}, t), width, height);
        DP(t, :, :, :) = dplace2(W(:, idx{t}, t),  W(:, idx{t}, t), width, height);
    end
    toc();

    setOutputField('DP', DP);
end

function dp = dplace2(w1, w2, width, height)
    width_ = width - 4;
    height_ = height - 4;
    dp = zeros(width_, height_, 9);
    
    for x = 1:width_
        for y = 1:height_
            idx = getIdx2(width, height, x, y); 
            w0 = w2(:, idx{5});
            for i = 1:9
                dp(x, y, i) = corr2(w0, w1(:, idx{i}));
            end
        end
    end
end

function idx = getIdx2(w, h, x0, y0)
    
    sz = [w, h];
    idx = {};
    for i = 1:3
        for j = 1:3
            idx{end + 1} = [];
            for x = i:(i + 2)
                for y = j:(j + 2)
                    idx{end}(end + 1) = sub2ind(sz, x0 + x - 1, y0 + y - 1);
                end
            end
        end
    end
end

%% 3
function DP = getDisplacement3()
    % Get displacements

    DP = getOutputField('DP');
    % DP = [];
    
    if ~isempty(DP)
        return
    end
    
    W = getW(); % linear kernels: number[neuron, location, time]
    % fixW = getFixW(); % average sensitivity at fixation period
    
    nt = getNumOfTimes(); % number of times
    [width, height] = getWidthHeightOfInterestGrid(); % width and height of target grid
    DP = zeros(nt, width - 2, height - 2, 9); % correlation between `fix` and time `t`
    
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    
    times = getTimes();
    
    fprintf('\nDisplacements:\n');
    tic();
    for t = 1:nt
        fprintf('Time: %d\n', times(t));
        % DP(t, :, :, :) = dplace3(fixW,  W(:, idx{t}, t), width, height);
        DP(t, :, :, :) = dplace3(W(:, idx{t}, t),  W(:, idx{t}, t), width, height);
    end
    toc();

    setOutputField('DP', DP);
end

function dp = dplace3(w1, w2, width, height)
    width_ = width - 2;
    height_ = height - 2;
    dp = zeros(width_, height_, 9);
    
    for x = 1:width_
        for y = 1:height_
            idx = getIdx3(width, height, x, y); 
            w0 = w2(:, idx{5});
            for i = 1:9
                dp(x, y, i) = corr(w0, w1(:, idx{i}));
            end
        end
    end
end

function idx = getIdx3(w, h, x0, y0)
    
    sz = [w, h];
    idx = {};
    for i = 1:3
        for j = 1:3
            idx{end + 1} = [];
            for x = i:(i + 0)
                for y = j:(j + 0)
                    idx{end}(end + 1) = sub2ind(sz, x0 + x - 1, y0 + y - 1);
                end
            end
        end
    end
end