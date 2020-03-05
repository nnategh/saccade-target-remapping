function fixCorr = getFixCorr()
    % Get correlation between fixation period and each time from saccade

    fixCorr = getOutputField('fixCorr');
    
    if ~isempty(fixCorr)
        return
    end
    
    W = getW(); % linear kernels: number[neuron, location, time]
    
    fixW = getFixW(); % average sensitivity at `fix`

    nt = size(W, 3); % number of times
    fixCorr = zeros(1, nt); % correlation between `fix` and time `t`
    
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    
    fprintf('\nCorrelations: ');
    tic();
    for t = 1:nt
        fixCorr(t) = corr2(fixW, W(:, idx{t}, t));
    end
    toc();

    setOutputField('fixCorr', fixCorr);
end
