function tlim = getTimeLimits()
    % Get time limits
    
    info = getInfo();
    tlim = unique([info.tmin, info.fix, info.sac, info.tmax]); % time limits
end