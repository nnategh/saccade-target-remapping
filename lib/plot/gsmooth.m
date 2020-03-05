function y = gsmooth(x, N)
    % Gaussian smoothing
    %
    % Parameters
    % ----------
    % - x: vector
    %   Input
    % - N: positive integer
    %   N-point Gaussian window
    %
    % Returns
    % -------
    % - y: vector
    %   Smoothed output
    
    if ~exist('N', 'var')
        N = 15;
    end
    
    y = smoothdata(x, 'gaussian', N);
end