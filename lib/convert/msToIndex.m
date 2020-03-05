function index = msToIndex(times)
    % Convert time from `ms from saccade onset` to index
    
    info = getInfo();
    index = times - info.tmin + 1;
end