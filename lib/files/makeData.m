function makeData()
    % Make data
    
    ids = getNeuronIDsFromInfo();
    
    fprintf('\nMake Data:\n');
    tic();
    parpool(6);
    parfor i = 1:numel(ids) % todo: parfor
        id = ids{i};
        fprintf('%d - %s\n', i, id);
        
        outFilename = getOutFilename(id);
        
        if isfile(outFilename)
            continue;
        end
        
        inFilename = getInFilename(id);
        
        if ~isfile(inFilename)
            disp(inFilename);
            disp('^^^');
            continue
        end
        
        data = getData(inFilename);
        saveData(outFilename, data);
    end
    toc();
end

function inFilename = getInFilename(id)
    % folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/scdata';
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/scdata';
    
    [session, channel, unit] = getSessionChannelUnit(id);
    name = sprintf('scdata_%d_%02d_%d.mat', session, channel, unit);
    inFilename = fullfile(folder, name);
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
    resp(isnan(resp)) = false; %? nan ->? false
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

function saveData(filename, data)
    save(filename, '-struct', 'data');
end

function outFilename = getOutFilename(id)
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/st-data/';
    if ~isfolder(folder)
        mkdir(folder);
    end
    outFilename = fullfile(folder, [id, '.mat']);
end
