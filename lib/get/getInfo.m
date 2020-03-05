function info = getInfo()
    % Get info
    
    % info
    width = 9;
    height = 9;
    tmin = -500; % -540 | -500
    tmax = 500; % 540 | 500
    dmin = 0;
    dmax = 150; % 200 | 150
    fix = [tmin, tmin + dmax];
    sac = [0, 30];
    N = 3; % Round to N number of digits
    
    % flag
    flag = struct(...
        'method', 'smm-response', ... % 'smodel-kernel' | 'smm-kernel' | 'smm-response'
        'displacement', '1x1', ... % '1pad' | '3x3' | '1x1'
        'probes', 'all', ... % 'all' | 'sub'
        'removedEffects', 'none' ... 'none' | 'all'
    );
    
    % folder
    % - assets
    assetsFolder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/saccade-target-remapping/assets/'; % './assets';
    % - data
    dataFolder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/barfak/';
    % - models
    switch flag.method
        case 'smodel-kernel'
            modelsFolder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/smodel/';
        case {'smm-kernel', 'smm-response'}
            modelsFolder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/smm/assets/results-z-15/';
    end
    % - results
    resultsFolder = fullfile(...
        assetsFolder, ...
        ['results-', flag.method, '-removed-', flag.removedEffects]);
    if ~isfolder(resultsFolder)
        mkdir(resultsFolder);
    end
    
    folder = struct(...
        'assets', assetsFolder, ...
        'data', dataFolder, ...
        'models', modelsFolder, ...
        'results', resultsFolder);
    
    % makeFolders(folder);
    
    % filename
    filename = struct(...
        'output', fullfile(folder.results, 'output.mat'));
    
    % plotting
    plotting = struct(...
        'formatType', 'png', ...
        'lineWidth', 4, ...
        'fontSize', 18);
    
    info = struct(...
        'width', width, ...
        'height', height, ...
        'tmin', tmin, ...
        'tmax', tmax, ...
        'dmin', dmin, ...
        'dmax', dmax, ...
        'fix', fix, ...
        'sac', sac, ...
        'N', N, ...
        'flag', flag, ...
        'folder', folder, ...
        'filename', filename, ...
        'plotting', plotting);
end


function makeFolders(folders)
    % Make folders
    
    fields = fieldnames(folders);
    for i = 1:numel(fields)
        field = fields{i};
        folder = folders.(field);
        if ~isfolder(folder)
            mkdir(folder);
        end
    end
end
