close('all');
clear();
clc();

folder = '/uufs/chpc.utah.edu/common/home/noudoost-group1/Barfak/skrns/';
listing = dir(fullfile(folder, '*.mat'));

filenames = {};
for i = 1:numel(listing)
    filename = fullfile(listing(i).folder, listing(i).name);
    
    [~, name, ~] = fileparts(filename);
    fprintf('%d - %s', i, name);
    
    if isWeird(filename)
        filenames{end + 1} = name;
        fprintf('\t***');
    end
    
    
    fprintf('\n');
end

fprintf('\n***\n\n');

for i = 1:numel(filenames)
    fprintf('%d - %s\n', i, filenames{i});
end

function tf = isWeird1(filename)
    load(filename, 'rf1_in_probes', 'rf2_in_probes', 'st_in_dva');
    
    rfv = rf2_in_probes - rf1_in_probes; % rf vector
    
    rfa = atan2d(rfv(2), rfv(1)); % rf angle
    rfa = round(rfa, 3);
    
    sacv = st_in_dva; % saccade vector
    
    saca = atan2d(sacv(2), sacv(1)); % saccade angle
    saca = round(saca, 3);
    
    tf = false;
    if rfa == 0 && saca == 180
        tf = true;
    end
end

function tf = isWeird(filename)
    load(filename, 'rf1_in_probes', 'rf2_in_probes', 'st_in_dva');
    
    rfv = rf2_in_probes - rf1_in_probes; % rf vector
    
    sacv = st_in_dva; % saccade vector
    
    tf = false;
    if dot(rfv, sacv) <= 0 || norm(sacv) < 5
        tf = true;
    end
end