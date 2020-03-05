function nt = getNumOfTimes()
    % Get number of times
    
    info = getInfo();
    nt = info.tmax - info.tmin + 1;
end