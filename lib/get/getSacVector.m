function sv = getSacVector()
    % Get saccade vector (fp1 -> fp2)
    %
    % Parameters
    % ----------
    % - filename: string
    %   Neuron filename
    % - N: number
    %   Round to N number of digits
    %
    % Returns
    % -------
    % - sv: number[2]
    %   Saccade vector (fp1 -> fp2);
    
    sv = getOutputField('sv');
end