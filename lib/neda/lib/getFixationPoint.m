function fp = getFixationPoint(ind)
    % Get `fixation point` probe location
    %
    % Parameters
    % ----------
    % - ind: 0 | 1
    %   Index of fixation point
    
    fpname = sprintf('neda01_fp%d', ind);
    
    fp = getOutputField(fpname);
    
    if ~isempty(fp)
        return
    end
    
    fp = getFP(ind, true);
    
    fp = fp(1, :);
    
    setOutputField(fpname, fp);
end
