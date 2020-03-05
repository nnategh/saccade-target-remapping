function plotPairwiseDistance()
    % Plot `PD`
    
    plot1();
    plot2();
    plot3();
    % plot4();
end

function plot1()
    PD = getPairwiseDistance();
    
    createFigure('Pairwise Distance');
    
    histogram(mean(PD), 'Normalization', 'probability');
    
    title('Pairwise distance of probe locations');
    
    xlabel('distance (probe)');
    ylabel('probability (unit)');
    yticks(0:0.05:1);
    
    set(gca, 'YGrid', 'on');
    
    setFontSize();
    
    saveFigure('pdist-hist');
end

function plot2()

    PD = getPairwiseDistance();
    % mean over distances
    PD = mean(PD, 2);
    
    info = getInfo();
    
    createFigure('Pairwise Distance');
    
    times = getTimes();
    plot(times, PD, 'LineWidth', info.plotting.lineWidth);
    
    title('Pairwise distance of probe locations (mean)');
    setTimeAxis();
    ylabel('Euclidean distance (unit)');
    % yticks(0:0.05:1);
    
    setFontSize();
    grid('on');
    box('on');
    
    saveFigure('pdist-mean');
end

function plot3()

    DP = getDisplacement();
    % remove [0, 0] displacement
    DP(:, :, :, 5) = [];
    % one minus the sample correlation
    DP = 1 - DP;
    % mean over locations and their 8-neighbours
    DP = mean(DP, [2, 3, 4]);
    
    info = getInfo();
    
    createFigure('Distance');
    
    times = getTimes();
    plot(times, DP, 'LineWidth', info.plotting.lineWidth);
    
    title('');
    setTimeAxis();
    ylabel('Distance (unit)');
    % yticks(0:0.05:1);
    
    setFontSize();
    grid('on');
    box('on');
    
    saveFigure('dist');
end

function plot4()
    fpr = 10;
    delay = 1 / fpr;
    vw = VideoWriter('corr.mp4', 'MPEG-4');
    vw.FrameRate = fpr;
    open(vw);

    DP = getDisplacement(); % number[time, x, y, 9]
    
    [nt, nx, ny, ~] = size(DP); % number of times, x, and y
    
    fig = createFigure('Correlation');
    
    fprintf('\nMake `corr.mp4` video.\n');
    tic();
    
    times = getTimes();
    for it = 1:nt
        fprintf('Time: %d\n', times(it));
        for ix = 1:nx
            for iy = 1:ny
                ip = (ny - iy) * nx + ix;% index of subplot
                subplot(ny, nx, ip);
                
                I = DP(it, ix, iy, :);
                I = reshape(I, 3, 3);
                I = I';
                
                imagesc(I);
                set(gca, 'YDir', 'normal');
                caxis([0, 1]);
                
                if ix == 1 && iy == 1
                    xticks([1, 2, 3]);
                    yticks([1, 2, 3]);
                    xticklabels({'-1', '0', '1'});
                    yticklabels({'-1', '0', '1'});
                    c = colorbar('eastoutside');
                    c.Label.String = 'Correlation (unit)';
                else
                    xticks([]);
                    yticks([]);
                end
                
                if iy == 1
                    xlabel(num2str(ix));
                end
                if ix == 1
                    ylabel(num2str(iy));
                end
                
                axis('square');
                setFontSize();
            end
        end
        
        writeVideo(vw, getframe(fig));
        pause(delay);
    end
    
    close(vw);
    toc();
end