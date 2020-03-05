function renameFiles()
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/yasin/smm/assets/results-z-15/';
    
    listing = dir(fullfile(folder, '*.mat'));
    
    fprintf('\nRename filenames:\n');
    tic();
    for i = 1:numel(listing)
        name = listing(i).name;
        fprintf('%3d - %s\n', i, name);
        
        filename = fullfile(folder, name);
        
        name = name(1:9);
        newFilename = fullfile(folder, [name, '.mat']);
        
        movefile(filename, newFilename);
    end
    toc();
end