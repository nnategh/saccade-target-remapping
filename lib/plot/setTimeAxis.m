function setTimeAxis()
    % Set time axis
    
    info = getInfo();
    
    xlabel('time from saccade onset (ms)');
    xticks(getTimeLimits());
    xlim([info.tmin, info.tmax]);
end