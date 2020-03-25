function ids = getNeuronIDsFromInfo()
    % Get neuron ids from `info` file
    
    filename = './assets/info_v20.mat';
    load(filename, 'info');
    
    ids = {};
    
    for i = 1:size(info, 1)
        if ...
                info.paper2(i) == 1 && ...
                info.isolation(i) == 1
            ids{end + 1, 1} = sprintf(...
                '%d%03d%d', ...
                info.id(i), info.ch(i), info.un(i));
        end
    end
end