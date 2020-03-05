function FP = getFP(fpind, toprobe)
    % Get fixation point locations
    
    if nargin < 1
        fpind = 1;
    end
    
    if nargin < 2
        toprobe = false;
    end
    
    info = getInfo();
    N = info.N;
    
    fpname = sprintf('fp%d', fpind);
    
    filenames = getDataFilenames();
    
    n = numel(filenames); % number of neurons
    FP = zeros(n, 2);
    
    for i = 1:n
        filename = filenames{i};
        
        S = load(filename, fpname);
        fp = round(S.(fpname), N);
        
        if toprobe
            load(filename, 'grid');
            
            fp = fp - [grid(1, 1, 1), grid(1, 1, 2)] + [1, 1]; % origin in probe unit is grid(1, 1)
            
            sx = grid(2, 1, 1) - grid(1, 1, 1);
            sy = grid(1, 2, 2) - grid(1, 1, 2);
    
            s = [sx, sy];
            
            fp = dvaToProbe(fp, s);
        end
        
        FP(i, :) = fp;
    end
end
