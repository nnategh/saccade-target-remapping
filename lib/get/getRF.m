function RF = getRF(rfind, todva)
    % Get receptive filed locations
    
    if nargin < 1
        rfind = 1;
    end
    
    if nargin < 2
        todva = false;
    end
    
    info = getInfo();
    N = info.N;
    
    rfname = sprintf('rf%d', rfind);
    
    filenames = getDataFilenames();
    
    n = numel(filenames); % number of neurons
    RF = zeros(n, 2);
    
    for i = 1:n
        filename = filenames{i};
        
        S = load(filename, rfname);
        rf = S.(rfname);
        
        if todva
            load(filename, 'grid');
            
            rf = [grid(rf(1), rf(2), 1), grid(rf(1), rf(2), 2)];
        end
        
        RF(i, :) = round(rf, N);
    end
end
