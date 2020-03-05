function modelFilenames = getModelFilenames()
    % Get model filenames
    
    folder = getModelsFolder();
    
    filenames = getFilenames();
    
    n = numel(filenames);
    modelFilenames = cell(n, 1);
    
    for i = 1:n
        modelFilenames{i} = fullfile(folder, [filenames{i}, '.mat']);
    end
    
end