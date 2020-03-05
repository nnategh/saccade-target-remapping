function makeSModelFiles()

    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/smodel/';
    if ~exist(folder, 'dir')
        mkdir(folder);
    end

    % filenames = getSkrnsFilenames();
    filenames = getFilenames();
    
    fprintf('\nMake S-Model files:\n');
    tic();
    parfor i = 1:numel(filenames)
        filename = filenames{i};
        
        [~, name, ~] = fileparts(filename);
        fprintf('%d - %s\n', i, name);
        
        data = getData(filename);
        
        outFilename = getOutFilename(folder, filename);
        
        saveData(outFilename, data);
    end
    toc();
    
end

function data = getData(filename)
    
    load(filename, 'skrn');

    data = struct('skrn', skrn);
end

function outFilename = getOutFilename(folder, filename)
    
    [~, name, ~] = fileparts(filename);
    name = extractDigits(name);
    
    outFilename = fullfile(folder, [name, '.mat']);
end

function saveData(filename, data)
    save(filename, '-struct', 'data');
end
