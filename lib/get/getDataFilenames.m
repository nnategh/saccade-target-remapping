function filenames = getDataFilenames()
    % Get name of neural data files

    listing = dir(fullfile(getDataFolder(), '*.mat'));
    
    n = numel(listing);
    filenames = cell(n, 1);
    
    for i = 1:n
        filenames{i} = fullfile(listing(i).folder, listing(i).name);
    end
end