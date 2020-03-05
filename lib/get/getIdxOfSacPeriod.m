function sacIdx = getIdxOfSacPeriod()
    % Get time indeces for saccade period
    
    info = getInfo();
    
    sacTimes = info.sac(1):info.sac(2); % fixation (presacadic) times
    sacIdx = msToIndex(sacTimes); % ms -> index
end