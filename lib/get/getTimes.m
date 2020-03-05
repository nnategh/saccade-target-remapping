function times = getTimes()
    % Get times
    
    info = getInfo();
    times = info.tmin:info.tmax;
end