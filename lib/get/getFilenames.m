function filenames = getFilenames()
    % Get filenames
    
    filenames = getOutputField('filenames');
    
    if ~isempty(filenames)
        return
    end
    
    filenames = getDataFilenames(); % all neurons
    
    % filter neurons
    filenames = filterByGrid(filenames); % neurons with same grid
    filenames = filterBySaccadeVector(filenames); % neurons with same saccade vector
    % filenames = filterByRF1ToRF2Direction(filenames, N); % neurons with rf1 to rf2 direction same as saccade vector
    
    % remove folder and extension from filenames
    for i = 1:numel(filenames)
        [~, filenames{i}, ~] = fileparts(filenames{i});
    end
    
    setOutputField('filenames', filenames);
end

% Probe locations (dva)
function filenames = filterByGrid(filenames)
    % Filter by grid of probe locations

    info = getInfo();
    N = info.N;
    
    G = {};
    
    fprintf('\nFilter neurons with the same grid: \n');
    tic();
    for i = 1:numel(filenames)
        filename = filenames{i};

        grid = getGrid(filename, N);
        flag = false;

        for j = 1:numel(G)
            grid_ = getGrid(G{j}{1}, N);

            if isequalGrids(grid, grid_)
                G{j}{end + 1} = filename;
                flag = true;
                break
            end
        end

        if ~flag
            G{end + 1} = {filename};
        end
    end

    imax = 0;
    nmax = -inf;
    fprintf('\n');
    for i = 1:numel(G)
        n = numel(G{i});

        if n > nmax
            nmax = n;
            imax = i;
        end

        fprintf('Index:%3d - Elements: %d\n', i, n);
    end

    fprintf('\nGroup with maximum elements\n');
    fprintf('Index:%3d - Elements: %d\n', imax, nmax);
    for j = 1:nmax
        [~, name, ~] = fileparts(G{imax}{j});
        fprintf('  %s\n', name);
    end
    
    filenames = G{imax}';
    
    % save `probe` to `dva` scale for `x` and `y` directions
    grid = getGrid(filenames{i}, N);
    
    % scale
    sx = grid(2, 1, 1) - grid(1, 1, 1);
    sy = grid(1, 2, 2) - grid(1, 1, 2);
    
    s = [sx, sy];
    
    setOutputField('s', s);
    
    toc();
end

function grid = getGrid(filename, N)
    % Get probe locations
    %
    % Parameters
    % ----------
    % - filename: string
    %   Neuron filename
    % - N: number
    %   Round to `N` digits
    %
    % Returns
    % -------
    % - grid: number[, , 2]
    %   X- and Y-coordinate of probe locations in dva
    
    load(filename, 'grid');
    
    grid = round(grid, N);
end

function tf = isequalGrids(g1, g2)
    tf = all(g1(:) == g2(:));
end

% Saccade vector (dva)
function filenames = filterBySaccadeVector(filenames)

    info = getInfo();
    N = info.N;
    
    G = {};
    
    fprintf('\nGet neuron filenames with the same saccade vector: \n');
    tic();
    for i = 1:numel(filenames)
        filename = filenames{i};

        sv = getSaccadeVector(filename, N);
        flag = false;

        for j = 1:numel(G)
            sv_ = getSaccadeVector(G{j}{1}, N);

            if isequalSaccadeVectors(sv, sv_)
                G{j}{end + 1} = filename;
                flag = true;
                break
            end
        end

        if ~flag
            G{end + 1} = {filename};
        end
    end

    imax = 0;
    nmax = -inf;
    fprintf('\n');
    for i = 1:numel(G)
        n = numel(G{i});

        if n > nmax
            nmax = n;
            imax = i;
        end

        fprintf('Index:%3d - Elements: %d\n', i, n);
    end

    fprintf('\nGroup with maximum elements\n');
    fprintf('Index:%3d - Elements: %d\n', imax, nmax);
    for j = 1:nmax
        [~, name, ~] = fileparts(G{imax}{j});
        fprintf('  %s\n', name);
    end
    
    filenames = G{imax}';
    
    % save saccade vector
    sv = getSaccadeVector(filenames{1}, N);
    setOutputField('sv', sv);
    
    toc();
end

function sv = getSaccadeVector(filename, N)
    % Get locations
    %
    % Parameters
    % ----------
    % - filename: string
    %   Neuron filename
    %
    % Returns
    % -------
    % - sv: number[2]
    %   Saccade vector (dva)
    
    load(filename, 'fp1', 'fp2');
    
    sv = fp2 - fp1;
    sv = round(sv, N);
end

function tf = isequalSaccadeVectors(sv, sv_)
    tf = all(sv == sv_);
end

% RF1 to RF2 direction
function filenames = filterByRF1ToRF2Direction(filenames, N)
    rfTheta = getRF1ToRF2Directions(filenames, N);
    sacTheta = getSaccadeDirection(filenames{1}, N);

    idx = rfTheta == sacTheta;
    
    filenames = filenames(idx);
end

function theta = getRF1ToRF2Directions(filenames, N)
    % Get rf1 -> rf2 vector
    
    n = numel(filenames); % number of neurons
    theta = zeros(n, 1);
    
    fprintf('\n RF1 to RF2 Directions: ');
    tic();
    for i = 1:n
        filename = filenames{i};
        
        load(filename, 'grid', 'rf1', 'rf2');
    
        x = round(grid(:, :, 1), N);
        y = round(grid(:, :, 2), N);
        
        rf1 = [x(rf1(1), rf1(2)), y(rf1(1), rf1(2))];
        rf2 = [x(rf2(1), rf2(2)), y(rf2(1), rf2(2))];
        
        v = rf2 - rf1;
        
        theta(i) = atan2d(v(2), v(1));
    end
    
    toc();
end

function theta = getSaccadeDirection(filename, N)
    
    sv = getSaccadeVector(filename, N);
    theta = round(atan2d(sv(2), sv(1)), N);
end

