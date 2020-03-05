function modelsFolder = getModelsFolder()
    % Get path of models folder
    %
    % Returns
    % -------
    % - modelsFolder: string
    %   Path of models folder
    
    info = getInfo();
    modelsFolder = info.folder.models;
end