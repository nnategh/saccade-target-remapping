function probe = dvaToProbe(dva, s)
    % Convert visual angle from `degree` to `probe`
    
    probe = round(dva ./ s);
end
