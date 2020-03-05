function PD = getPairwiseDistance()
    % Get pairwise distances between representation of probe locations in
    % visual neuron population

    PD = getOutputField('PD');
    
    if ~isempty(PD)
        return
    end
    
    W = getW(); % linear kernels: number[neuron, location, time]
    
    idx = getIdxOfInterestLocations(); % one-dimensional probe indeces
    
    nt = getNumOfTimes(); % number of times
    nl = numel(idx{1}); % number of target probe locations
    PD = zeros(nt, nl * (nl - 1) / 2); % pairwise distance between probe location at each time `t`
    
    fprintf('\nPairwise Distances: ');
    tic();
    for t = 1:nt
        PD(t, :) = pdist(W(:, idx{t}, t)');
    end
    toc();

    setOutputField('PD', PD);
end
