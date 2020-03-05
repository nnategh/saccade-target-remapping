function fixW = getFixW()
    % Get average sensitivity at fixation period
    
    W = getW(); % linear kernels: number[neuron, location, time]
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    fix = getIdxOfFixPeriod(); % time indeces of fixation period
    fixW = mean(W(:, idx{1}, fix), 3); % average sensitivity at `fix`
end