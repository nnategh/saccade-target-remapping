function setOutputField(fieldName, fieldValue)
    % Set the given field in the `output.mat` file
    
    S.(fieldName) = fieldValue;

    outputFilename = getOutputFilename();
    
    if exist(outputFilename, 'file')
        save(outputFilename, '-struct', 'S', '-append');
    else
        save(outputFilename, '-struct', 'S');
    end
end