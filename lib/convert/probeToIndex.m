function ind = probeToIndex(probes)
    % Convert location from `probe` to `index`
    
    info = getInfo();
    ind = sub2ind([info.width, info.height], probes(:, 1), probes(:, 2));
end