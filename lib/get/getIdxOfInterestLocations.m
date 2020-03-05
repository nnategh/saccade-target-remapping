function [idx, width_, height_] = getIdxOfInterestLocations()
    % Get indeces of interest locations (subset of all possible locations)
    
    info = getInfo();
    switch info.flag.probes
        case 'all'
            [idx, width_, height_] = getIdxOfInterestLocations1();
        case 'sub'
            [idx, width_, height_] = getIdxOfInterestLocations2();
    end
end

function [idx, width_, height_] = getIdxOfInterestLocations1()
    % Get indeces of interest locations (subset of all possible locations)
    
    idx = getOutputField('idx');
    width_ = getOutputField('width_');
    height_ = getOutputField('height_');
    
    if ~isempty(idx) && ~isempty(width_) && ~isempty(height_)
        return
    end
    
    [width_, height_] = getWidthHeightOfGrid();
    
    probes = zeros(0, 2);
    for x = 1:width_
        for y = 1:height_
            probes(end + 1, :) = [x, y];
        end
    end
    
    ind = probeToIndex(probes);
    
    nt = getNumOfTimes();
    idx = cell(nt, 1);
    for it = 1:nt
        idx{it} = ind;
    end
    
    setOutputField('idx', idx);
    setOutputField('width_', width_);
    setOutputField('height_', height_);
end

function [idx, width_, height_] = getIdxOfInterestLocations2()
    % Get indeces of interest locations (subset of all possible locations)
    
    idx = getOutputField('idx');
    width_ = getOutputField('width_');
    height_ = getOutputField('height_');
    
    if ~isempty(idx) && ~isempty(width_) && ~isempty(height_)
        return
    end
    
    nt = getNumOfTimes();
    idx = cell(nt, 1);
    
    [width, height] = getWidthHeightOfGrid();
    sv = getSacVector(); % saccade vector (dva)
    s = getProbeToDVAScale(); % scale (dva per probe)
    
    [probes, width_, height_] = getProbesOfFixPeriod(dvaToProbe(sv, s), width, height); % probe locations
    
    sac = getIdxOfSacPeriod();
    
    % before saccade
    ind = probeToIndex(probes); % one-dimensional probe indeces;
    for it = 1:(sac(1) - 1) % for each time `t`
        idx{it} = ind;
    end
    % saccade
    dt = sac(end) - sac(1); % delta time
    for it = sac(1):sac(end) % for each time `t`
        u = dvaToProbe(((it - sac(1)) / dt) * sv, s);
        ind = probeToIndex(probes +  u);
        idx{it} = ind;
    end
    % after saccade
    for it = (sac(end) + 1):nt % for each time `t`
        idx{it} = ind;
    end
    
    setOutputField('idx', idx);
    setOutputField('width_', width_);
    setOutputField('height_', height_);
end

function [probes, width_, height_] = getProbesOfFixPeriod(sv, width, height)
    % Get safe probe locations by considering given saccade vector
    
    dx = sv(1);
    if dx < 0
        xmin = 1 - dx;
        xmax = width;
    else
        xmin = 1;
        xmax = width - dx;
    end
    
    dy = sv(2);
    if dy < 0
        ymin = 1 - dy;
        ymax = height;
    else
        ymin = 1;
        ymax = height - dy;
    end
    
    probes = zeros(0, 2);
    for x = xmin:xmax
        for y = ymin:ymax
            probes(end + 1, :) = [x, y];
        end
    end
    
    width_ = xmax - xmin + 1;
    height_ = ymax - ymin + 1;
end
