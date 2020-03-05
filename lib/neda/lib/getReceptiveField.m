function rf = getReceptiveField(ind)
    % Get `receptive field` probe location
    %
    % Parameters
    % ----------
    % - ind: 0 | 1
    %   Index of receptive field
    
    rfname = sprintf('neda01_rf%d', ind);
    
    rf = getOutputField(rfname);
    
    if ~isempty(rf)
        return
    end
    
    rf = getRF(ind);
    
    setOutputField(rfname, rf);
end
