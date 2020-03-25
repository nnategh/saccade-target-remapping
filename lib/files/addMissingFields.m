function addMissingFields()
    
    ids = getNeuronIDsFromInfo();
    
    fprintf('\nAdd missing fields:\n');
    tic();
    parfor i = 1:numel(ids) % todo: parfor
        id = ids{i};
        fprintf('%d - %s\n', i, id);
        
        inFilename = getInFilename(id);
        data = getData(inFilename);
        outFilename = getOutFilename(id);
        appendData(outFilename, data);
    end
    toc();
    
end

function inFilename = getInFilename(id)
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns';
    
    [session, channel, unit] = getSessionChannelUnit(id);
    name = sprintf('neuron_%d_%d_%d.mat', session, channel, unit);
    inFilename = fullfile(folder, name);
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

function outFilename = getOutFilename(id)
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/st-data/';
    outFilename = fullfile(folder, [id, '.mat']);
end

function appendData(filename, data)
    save(filename, '-struct', 'data', '-append');
end
