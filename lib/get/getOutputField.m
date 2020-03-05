function fieldValue = getOutputField(fieldName)
    % Get field of `output.mat` file
    
    fieldValue = [];

    outputFilename = getOutputFilename();
    
    if exist(outputFilename, 'file')
        info = who('-file', outputFilename);
        if ismember(fieldName, info)
            S = load(outputFilename, fieldName);
            fieldValue = S.(fieldName);
        end
    end
end