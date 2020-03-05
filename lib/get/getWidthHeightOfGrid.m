function [width, height] = getWidthHeightOfGrid()
    % Get width and height of grid of probe locations
    
    info = getInfo();
    width = info.width;
    height = info.height;
end