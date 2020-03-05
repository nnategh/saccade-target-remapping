function plotEffectDist(varargin)
    % Plot distribution of neurons with/without given effect ('rf', 'ff',
    % 'st', 'pa')
    
    disp('Neural Effects:');
    disp(varargin);
    
    neuronNames = {};
    
    for i = 1:numel(varargin)
        neuronNames = intersect(neuronNames, getNeuronsWithEffect(varargin{i}));
    end
    
    fprintf('Number of neurons: %d', numel(neuronNames));    
end
