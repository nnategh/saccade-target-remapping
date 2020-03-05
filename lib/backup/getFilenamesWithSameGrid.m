function filenames = getFilenamesWithSameGrid(dataFolder)

    if nargin < 1
        dataFolder = getDataFolder('local');
    end

    listing = dir(fullfile(dataFolder, '*.mat'));
    if isempty(listing)
        warning('No files!');
        return;
    end
    
    G = {};
    
    fprintf('\nGet neuron filenames with the same grid: \n');
    tic();
    for i = 1:numel(listing)
        filename = fullfile(listing(i).folder, listing(i).name);

        [x, y] = getXY(filename);
        flag = false;

        for j = 1:numel(G)
            [x_, y_] = getXY(G{j}{1});

            if isequalXY(x, y, x_, y_)
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
    
    filenames = G{imax};
    
    toc();
end

function [x, y] = getXY(filename, N)
    % Get locations
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
    % - x: number[, ]
    %   X-coordinate of probe locations in dva
    % - y: number[, ]
    %   Y-coordinate of probe locations in dva
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'XoB', 'YoB');
    
    x = XoB;
    y = YoB;
    
    x = round(x, N);
    y = round(y, N);
end

function tf = isequalXY(x1, y1, x2, y2)
    tf = all(x1 == x2) & all(y1 == y2);
end
