function resyktsFolder = getResultsFolder()
    % Get path of results folder
    %
    % Returns
    % -------
    % - resultsFolder: string
    %   Path of results folder
    
    info = getInfo();
    resyktsFolder = info.folder.results;
end