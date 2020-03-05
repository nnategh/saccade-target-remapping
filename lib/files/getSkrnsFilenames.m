function filenames = getSkrnsFilenames()
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns/';
    
    listing = dir(fullfile(folder, '*.mat'));
    n = numel(listing);
    filenames = cell(n, 1);
    for i = 1:n
        filenames{i} = fullfile(listing(i).folder, listing(i).name);
    end
end