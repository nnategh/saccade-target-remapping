function plotFixCorr()
    % Plot `fixCorr`
    
    fixCorr = getFixCorr();
    times = getTimes();
    
    info = getInfo();

    createFigure('Location Sensitivity');
    
    plot(times, fixCorr, ...
        'LineWidth', info.plotting.lineWidth);
    
    title('Correlation between fixation template and each time');
    
    setTimeAxis();
    setCorrAxis();
    setFontSize();
    
    box('on');
    grid('on');
    
    saveFigure('fix-corr');
end