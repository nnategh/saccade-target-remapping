function setFontSize()
    % Set font size
    
    info = getInfo();
    set(gca, 'FontSize', info.plotting.fontSize);
end