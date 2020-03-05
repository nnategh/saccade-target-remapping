function [theta, rho, RFFP] = getRFToFP(rfind, fpind, toprobe)
    % Get receptive filed to fixation point distance
    
    if nargin < 1
        rfind = 1;
    end
    
    if nargin < 2
        fpind = 1;
    end
    
    if nargin < 3
        toprobe = false;
    end
    
    RF = getRF(rfind, ~toprobe);
    FP = getFP(fpind, toprobe);
    RFFP = FP - RF;
    
    [theta, rho] = cart2pol(RFFP(:, 1), RFFP(:, 2));
end
