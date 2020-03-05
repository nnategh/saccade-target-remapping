close('all');
clear();
clc();

filenames = getFilenames()';
scdataFilenames = getScdataFilenames();

filenames = toOnlyDigitsFilenames(filenames);
scdataFilenames = toOnlyDigitsFilenames(scdataFilenames);

diffFilenames = setdiff(filenames, scdataFilenames);

celldisp(diffFilenames);

function scdataFilenames = getScdataFilenames()
    
    folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/scdata/';
    
    listing = dir(fullfile(folder, '*.mat'));
    n = numel(listing);
    
    scdataFilenames = cell(n, 1);
    
    for i = 1:n
        scdataFilenames{i} = fullfile(listing(i).folder, listing(i).name);
    end
end

function filenames = toOnlyDigitsFilenames(filenames)
    for i = 1:numel(filenames)
        [~, name, ~] = fileparts(filenames{i});
        name = extractDigits(name);
        filenames{i} = name;
    end
end

function name = extractDigits(name)
    name = name(name >= '0' & name <= '9');
end