function makeSModelFiles()

    folder = 'D:/data/smodel';
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    ids = getNeuronIDsFromInfo();
    
    fprintf('\nMake S-Model files:\n');
    tic();
    parfor i = 1:numel(ids)
        id = ids{i};
        
        fprintf('%d - %s\n', i, id);
        
        data = getData(id);        
        outFilename = getOutFilename(folder, id);
        saveData(outFilename, data);
    end
    toc();
    
end

function data = getData(id)
    % s-models folder
    folder = 'D:/data/smodels-raw';
    
    [session, channel, unit] = getSessionChannelUnit(id);
    id = sprintf('%d_%d_%d', session, channel, unit);
    
    folder = fullfile(folder, id);
    
    % params
    % - linear
    stm = zeros(5, 9, 9, 1081, 200);
    psk = zeros(5, 1081, 176);
    off = zeros(5, 1081);
    % - non-linear
    nln = zeros(5, 2);
    
    for fold = 0:4 % for each fold
        filename = fullfile(...
            folder, ...
            num2str(fold), ...
            sprintf('fold_%d.mat', fold));
        
        load(filename, 'nProfile');
        
        stm(fold + 1, :, :, :, :) = nProfile.set_of_kernels.stm.knl;
        psk(fold + 1, :, :) = nProfile.set_of_kernels.psk.knl;
        off(fold + 1, :) = nProfile.set_of_kernels.off.knl;
        
        nln(fold + 1, 1) = nProfile.set_of_params.b0; 
        nln(fold + 1, 2) = nProfile.set_of_params.params(1);
    end
    
    data = struct(...
        'stm', stm, ...
        'psk', psk, ...
        'off', off, ...
        'nln', nln);
end

function outFilename = getOutFilename(folder, id)
    outFilename = fullfile(...
        folder, ...
        [id, '.mat']);
end

function saveData(filename, data)
    save(filename, '-struct', 'data');
end
