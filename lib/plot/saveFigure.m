function saveFigure(name)
    % Save figure
    
    info = getInfo();
    
    fullfilename = fullfile(info.folder.results, name);
    folder = fileparts(fullfilename);
    if ~isfolder(folder)
        mkdir(folder);
    end
    
    saveas(gcf, fullfilename, info.plotting.formatType);
end