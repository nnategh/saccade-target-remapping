function W = getW()
    % get W
    %
    % Returns
    % =======
    % - W: number[neuron, location, time]
    %   Dynamic location representation by visual neurons
    
    info = getInfo();
    
    switch info.flag.method
        case 'smodel-kernel'
            W = getWSModelKernel();
        case 'smm-kernel'
            W = getWSMMKernel();
        case 'smm-response'
            W = getWSMMResponse();
    end
end

function W = getWSModelKernel()
    
    W = getOutputField('W');
    
    if ~isempty(W)
        return
    end
    
    filenames = getModelFilenames(); % get model filenames with same grid and saccade vector
    nn = numel(filenames); % number of neurons
    [width, height] = getWidthHeightOfGrid();
    
    W = zeros(nn, width * height, getNumOfTimes());
    
    fprintf('\nLinear kernels: \n');
    tic();
    parfor i = 1:nn
        filename = filenames{i};
        
        [~, name, ~] = fileparts(filename);
        fprintf('%3d - %s\n', i, name);
        
        S = load(filename, 'skrn');
        w = S.skrn;
        
        % folds
        % w = squeeze(skrn(1, :, :, :, :));
        w = squeeze(mean(w, 1));
        
        % normalize
        % w = w ./ max(w(:));

        % delay
        w = reshape(w, size(w, 1) * size(w, 2), size(w, 3), size(w, 4)); % location -> index
        % w = mean(w, 3); % mean over `delay` dimension
        w = max(w, [], 3); % max over `delay` dimension
        
        W(i, :, :) = w;
    end
    
    setOutputField('W', W);
    
    toc();
end

function W = getWSMMKernel()
    
    W = getOutputField('W');
    
    if ~isempty(W)
        return
    end
    
    filenames = getModelFilenames(); % get model filenames with same grid and saccade vector
    nn = numel(filenames); % number of neurons
    [width, height] = getWidthHeightOfGrid();
    W = zeros(nn, width * height, getNumOfTimes());
    
    fprintf('\nLinear kernels: \n');
    tic();
    parfor i = 1:nn
        filename = filenames{i};
        
        [~, name] = fileparts(filename);
        fprintf('%3d - %s\n', i, name);
        
        S = load(filename, 'W');
        w = S.W;
    
        w = reshape(w, size(w, 1) * size(w, 2), size(w, 3), size(w, 4)); % location -> index
        
        % w = mean(w, 3); % mean over `delay` dimension
        w = max(w, [], 3); % max over `delay` dimension
        
        W(i, :, :) = w;
    end
    
    setOutputField('W', W);
    
    toc();
end

function W = getWSMMResponse()
    
    W = getOutputField('W');
    
    if ~isempty(W)
        return
    end
    
    filenames = getModelFilenames(); % get model filenames with same grid and saccade vector
    nn = numel(filenames); % number of neurons
    [width, height] = getWidthHeightOfGrid();
    nl = width * height; % number of locations
    sz = [width, height]; % size of grid
    nt = getNumOfTimes(); % number of times
    
    W = zeros(nn, nl, nt);
    
    fprintf('\nLinear kernels: \n');
    mainTimer = tic();
    parfor i = 1:nn
        filename = filenames{i};
        
        [~, name] = fileparts(filename);
        fprintf('%3d - %s', i, name);
        tic();
        
        S = load(filename, 'models', 'W');
        w = sum(S.W, 4); % sum over delay dimension
        models = S.models;
    
        for t = 1:nt
            model = models{t};
            
            for l = 1:nl
                [x, y] = ind2sub(sz, l);
                W(i, l, t) = model.predict(w(x, y, t));
            end
        end
        toc();
    end
    
    % nan -> 0
    W(isnan(W)) = 0;
    
    % remove effects
    info = getInfo();
    switch info.flag.removedEffects
        case 'all'
            W = removeEffects(W);
    end
    
    setOutputField('W', W);
    
    toc(mainTimer);
end

function W = removeEffects(W)
    tidx1 = msToIndex(0:100);
    tidx2 = msToIndex(101:201);
    W(:, :, tidx1) = W(:, :, tidx2);
end
