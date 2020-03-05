function dataFolder = getDataFolder()
    % Get path of data folder
    %
    % Returns
    % -------
    % - dataFolder: string
    %   Path of data folder
    
    info = getInfo();
    dataFolder = info.folder.data;
end