function makeData()
    % Make data
    
    dataFolder = 'data';
    if ~exist(dataFolder, 'dir')
        mkdir(dataFolder);
    end
    
    filenames = getFilenames();
    filenames = modifyFilenames(filenames);
    
    fprintf('\nMake data:\n');
    tic();
    
    parfor i = 1:numel(filenames)
        filename = filenames{i};
        
        [~, name, ~] = fileparts(filename);
        fprintf('%3d - %s\n', i, name);
        
        data = getData(filename);
        
        saveData(data, dataFolder, filename);
    end
    toc();
end

function filenames = modifyFilenames(filenames)
    % Modify (change folder and name) of filenames
    % scdata2_181026_61_1.mat
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/scdata';
    
    for i = 1:numel(filenames)
        [~, name, ~] = fileparts(filenames{i});
        name = strrep(name, 'neuron', 'scdata');
        filenames{i} = fullfile(folder, [name, '.mat']);
    end
end

function data = getData(filename)
    % Get data
    load(filename, 'scdata');

    % time of saccade
    tsac = scdata.tsaccade;

    % stim
    stim = codeStim(scdata.stim); % code stimuli
    stim = sacAlign(stim, tsac); % saccade align
    stim(isnan(stim)) = 0; % `nan` to `0`
    stim = uint8(stim); % cast type

    % resp
    resp = sacAlign(scdata.resp, tsac); % saccade align
    resp = logical(resp); % cast type

    % cond
    cond = scdata.condition;
    cond = uint8(cond); % cast type

    data = struct(...
        'stim', stim, ...
        'resp', resp, ...
        'cond', cond);
end

function cstim = codeStim(stim)
    % Make coded stimulus
    
    [N, ~, ~, T] = size(stim);
    cstim = zeros(N, T);
    for i = 1:N
        for t = 1:T
            prb = find(squeeze(stim(i, :, :, t)), 1);
            if isempty(prb)
                cstim(i, t) = 0;
            else
                cstim(i, t) = prb;
            end
        end
    end
end

function adata = sacAlign(data, tsac)
    % Saccade aligned
    %
    % Returns
    % =======
    % - adata: number[, ]
    %   Aligned data

    times = (-750:750) + tsac;
    [m, n] = size(times);

    adata = zeros(m, n);

    for i = 1:m
        adata(i, :) = data(i, times(i, :));
    end
end

function saveData(data, dataFolder, filename)
    save(...
        fullfile(dataFolder, getOutFilename(filename)), ...
        '-struct', 'data');
end

function outFilename = getOutFilename(filename)
    load(filename, 'id', 'ch', 'un');
    outFilename = [id, ch, un, '.mat'];
end
