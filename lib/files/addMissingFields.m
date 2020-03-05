function addMissingFields()
    
    % filenames = getSkrnsFilenames();
    filenames = getFilenames();
    
    fprintf('\nAdd missing fields:\n');
    tic();
    parfor i = 1:numel(filenames)
        filename = filenames{i};
        
        [~, name, ~] = fileparts(filename);
        fprintf('%d - %s\n', i, name);
        
        data = getData(filename);
        
        outFilename = getOutFilename(filename);
        
        appendData(outFilename, data);
    end
    toc();
    
end

function data = getData(filename)
    
    load(filename, ...
        'rf1_in_probes', ...
        'rf2_in_probes', ...
        'st_in_dva', ...
        'XoB', ...
        'YoB');

    data = struct(...
        'rf1', rf1_in_probes, ...
        'rf2', rf2_in_probes, ...
        'fp1', [0, 0], ...
        'fp2', st_in_dva, ...
        'grid', getGrid(XoB, YoB));
end

function grid = getGrid(XoB, YoB)
    [m, n] = size(XoB);
    
    grid = zeros(m, n, 2);
    
    for i = 1:m
        for j = 1:n
            grid(i, j, :) = [XoB(i, j), YoB(i, j)];
        end
    end
end

function outFilename = getOutFilename(filename)
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/barfak/';
    
    [~, name, ~] = fileparts(filename);
    name = extractDigits(name);
    
    outFilename = fullfile(folder, [name, '.mat']);
end

function appendData(filename, data)
    save(filename, '-struct', 'data', '-append');
end
