function setCorrAxis()
    % Set correlation axis
    
    % max of y-data
    ax = gca();
    ymax = round(max(ax.Children(1).YData), 1) + 0.1;
    
    ylim([0, ymax]);
    yticks(0:0.1:ymax);
    ylabel('correlation (unit)');
end