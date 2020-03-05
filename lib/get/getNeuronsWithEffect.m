function neuronNames = getNeuronsWithEffect(effectName)
    % Get name of neurons with given effect name
    
    switch effectName
        case 'rf'
            neuronNames = getNeuronsWithRF();
    end
end

function neuronNames = getNeuronsWithRF()
    % Get name of neurons with `receptive field` effect
    
    error('Not implemented!');
end
