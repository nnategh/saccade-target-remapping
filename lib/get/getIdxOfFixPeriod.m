function fixIdx = getIdxOfFixPeriod()
    % Get indeces of times for fixation period

    info = getInfo();
    
    fixTimes = info.fix(1):info.fix(2); % fixation (presacadic) times
    fixIdx = msToIndex(fixTimes); % time -> index
end