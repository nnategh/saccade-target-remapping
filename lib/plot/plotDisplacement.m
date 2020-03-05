function plotDisplacement()
    % Plot displacements
    
    info = getInfo();
    
    switch info.flag.displacement
        case '1pad'
            plot1();
            plot2();
        case {'3x3', '1x1'}
            plot3();
            plot4();
            plot5();
    end
end

function plot1()
    % Plot histogram of displacements
    
    DP = getDisplacement();
    
    createFigure('Displacement');
    
    c = {};
    for x = -1:1
        for y = -1:1
            c{end + 1} = sprintf('(%d, %d)', x, y);
        end
    end
    
    bar(categorical(c), mean(DP));
    
    title('Displacement');
    xlabel('(x, y) coordinate (probe)');
    ylabel('correlation (unit)');
    
    yticks(0:0.05:1);
    
    set(gca, 'YGrid', 'on');
    
    setFontSize();
    
    saveFigure('DP-hist');
end

function plot2()
    % Plot timeseries of displacements
    
    DP = getDisplacement();
    
    
    createFigure('Displacement');
    
    d = [];
    for x = -1:1
        for y = -1:1
            d(end + 1, :) = [x, y];
        end
    end
    
    DP(:, 5) = [];
    d(5, :) = [];
    
    T = size(DP, 1);
    
    x = zeros(T, 1);
    y = zeros(T, 1);
    r = zeros(T, 1);
    a = zeros(T, 1);
    
    dx = d(:, 1);
    dy = d(:, 2);
    for t = 1:T
        w = DP(t, :);
        w = abs(w);
        w = w ./ sum(w);
        
        x(t) = dot(w, dx);
        y(t) = dot(w, dy);
        r(t) = sqrt(x(t) ^ 2 + y(t) ^ 2);
        a(t) = atan2d(y(t), x(t));
    end
    
    rows = 4;
    cols = 1;
    
    % x
    subplot(rows, cols, 1);
    plotTS(x);
    title('x');
    xlabel('');
    ylim([-1, 1]);
    yticks(-1:0.5:1);
    % y
    subplot(rows, cols, 2);
    plotTS(y);
    title('y');
    xlabel('');
    ylim([-1, 1]);
    yticks(-1:0.5:1);
    % r
    subplot(rows, cols, 3);
    plotTS(r);
    title('\rho');
    xlabel('');
    ylim([0, 1]);
    yticks(0:0.5:1);
    % a
    subplot(rows, cols, 4);
    plotTS(a);
    title('\theta');
    ylim([-180, 180]);
    yticks(-180:90:180);
    
    % Local functions
    function plotTS(v)
        % Plot timeseries
        info = getInfo();
        
        times = getTimes();
        
        plot(times, v, 'LineWidth', info.plotting.lineWidth);
        setTimeAxis();
        setFontSize();
        grid('on');
        box('on');
    end

    saveFigure('DP-mean');
end

function plot3()
    % Plot timeseries of displacements
    
    DP = getDisplacement();
    
    u = [];
    for x = -1:1
        for y = -1:1
            u(end + 1, :) = [x, y];
        end
    end
    
    % remove [0, 0] displacement
    DP(:, :, :, 5) = [];
    u(5, :) = [];
    
    [nt, nx, ny, ~] = size(DP);
    
    dx = zeros(nt, nx, ny);
    dy = zeros(nt, nx, ny);
    r = zeros(nt, nx, ny);
    a = zeros(nt, nx, ny);
    
    ux = u(:, 1);
    uy = u(:, 2);
    for t = 1:nt
        for x = 1:nx
            for y = 1:ny
                w = squeeze(DP(t, x, y, :));
                w = abs(w);
                w = w ./ sum(w);

                dx(t, x, y) = dot(w, ux);
                dy(t, x, y) = dot(w, uy);
                r(t, x, y) = sqrt(dx(t, x, y) ^ 2 + dy(t, x, y) ^ 2);
                a(t, x, y) = atan2d(dy(t, x, y), dx(t, x, y));
            end
        end
    end
    
    [~, nx, ny] = size(dx);
    folder = getResultsFolder();
    for x = 1:nx
        for y = 1:ny 
    
        createFigure('Displacement');

        Dx = dx(:, x, y);
        Dy = dy(:, x, y);
        R = r(:, x, y);
        A = a(:, x, y);

        rows = 4;
        cols = 1;

        % x
        subplot(rows, cols, 1);
        plotTS(Dx);
        title('x');
        xlabel('');
%         ylim([-1, 1]);
%         yticks(-1:0.5:1);
        % y
        subplot(rows, cols, 2);
        plotTS(Dy);
        title('y');
        xlabel('');
%         ylim([-1, 1]);
%         yticks(-1:0.5:1);
        % r
        subplot(rows, cols, 3);
        plotTS(R);
        title('\rho');
        xlabel('');
%         ylim([0, 1]);
%         yticks(0:0.5:1);
        % a
        subplot(rows, cols, 4);
        plotTS(A);
        title('\theta');
%         ylim([-180, 180]);
%         yticks(-180:90:180);
        
        suptitle(sprintf('[%d, %d]', x, y));
        
        saveas(gcf, fullfile(...
            folder, ...
            sprintf('DP%d%d.png', x, y)));
        
        close('all');
        
        end
    end
    
    
    % Local functions
    function plotTS(v)
        % Plot timeseries
        info = getInfo();
        
        times = getTimes();
        
        plot(times, v, 'LineWidth', info.plotting.lineWidth);
        setTimeAxis();
        setFontSize();
        grid('on');
        box('on');
    end
end

function plot4()
    % Plot timeseries of displacements
    
    DP = getDisplacement();
    
    u = [];
    for x = -1:1
        for y = -1:1
            u(end + 1, :) = [x, y];
        end
    end
    
    % remove [0, 0] displacement
    DP(:, :, :, 5) = [];
    u(5, :) = [];
    
    [nt, nx, ny, ~] = size(DP);
    
    dx = zeros(nt, nx, ny);
    dy = zeros(nt, nx, ny);
    r = zeros(nt, nx, ny);
    a = zeros(nt, nx, ny);
    
    ux = u(:, 1);
    uy = u(:, 2);
    for t = 1:nt
        for x = 1:nx
            for y = 1:ny
                w = squeeze(DP(t, x, y, :));
                w = abs(w);
                w = w ./ sum(w);

                dx(t, x, y) = dot(w, ux);
                dy(t, x, y) = dot(w, uy);
                r(t, x, y) = sqrt(dx(t, x, y) ^ 2 + dy(t, x, y) ^ 2);
                a(t, x, y) = atan2d(dy(t, x, y), dx(t, x, y));
            end
        end
    end
    
    dx = mean(dx, [2, 3]);
    dy = mean(dy, [2, 3]);
    r = mean(r, [2, 3]);
    a = mean(a, [2, 3]);
    
    rows = 4;
    cols = 1;

    createFigure('Displacement');
    % x
    subplot(rows, cols, 1);
    plotTS(dx);
    title('x');
    xlabel('');
%     ylim([-1, 1]);
%     yticks(-1:0.5:1);
    % y
    subplot(rows, cols, 2);
    plotTS(dy);
    title('y');
    xlabel('');
%     ylim([-1, 1]);
%     yticks(-1:0.5:1);
    % r
    subplot(rows, cols, 3);
    plotTS(r);
    title('\rho');
    xlabel('');
%     ylim([0, 1]);
%     yticks(0:0.5:1);
    % a
    subplot(rows, cols, 4);
    plotTS(a);
    title('\theta');
%     ylim([-180, 180]);
%     yticks(-180:90:180);

    % saveas(gcf, fullfile(getResultsFolder(), 'DP-mean.png'));
    saveFigure('DP-mean');    
    
    % Local functions
    function plotTS(v)
        % Plot timeseries
        info = getInfo();
        
        times = getTimes();
        
        plot(times, v, 'LineWidth', info.plotting.lineWidth);
        setTimeAxis();
        setFontSize();
        grid('on');
        box('on');
    end
end

function plot5()
    % Plot timeseries of displacements
    
    DP = getDisplacement();
    
    u = [];
    for x = -1:1
        for y = -1:1
            u(end + 1, :) = [x, y];
        end
    end
    
    % remove [0, 0] displacement
    DP(:, :, :, 5) = [];
    u(5, :) = [];
    
    [nt, nx, ny, ~] = size(DP);
    
    dx = zeros(nt, nx, ny);
    dy = zeros(nt, nx, ny);
    r = zeros(nt, nx, ny);
    a = zeros(nt, nx, ny);
    
    ux = u(:, 1);
    uy = u(:, 2);
    for t = 1:nt
        for x = 1:nx
            for y = 1:ny
                w = squeeze(DP(t, x, y, :));
                w = abs(w);
                w = w ./ sum(w);

                dx(t, x, y) = dot(w, ux);
                dy(t, x, y) = dot(w, uy);
                r(t, x, y) = sqrt(dx(t, x, y) ^ 2 + dy(t, x, y) ^ 2);
                a(t, x, y) = atan2d(dy(t, x, y), dx(t, x, y));
            end
        end
    end
    
    [~, nx, ny] = size(dx);
    folder = getResultsFolder();
    
    tidx = msToIndex(0:100);
    interestRho = zeros(nx, ny);
    for x = 1:nx
        for y = 1:ny 
            interestRho(x, y) = mean(r(tidx, x, y));
            % interestRho(x, y) = max(r(tidx, x, y));
        end
    end
    
    [~, lidx] = maxk(interestRho(:), ceil(0.1 * numel(interestRho)));
    
    % print x/y locations
    [lx, ly] = ind2sub([nx, ny], lidx);
    disp('Locations with maximum displacements');
    disp([lx, ly]);
    
    r = reshape(r, nt, nx * ny);
    r = mean(r(:, lidx), 2);
    
    createFigure('Displacement');
    
    plotTS(r);
    title('\rho');
    xlabel('');
    
    % saveas(gcf, fullfile(getResultsFolder(), 'DP-interest-locs.png'));
    saveFigure('DP-interest-locs');
    
    % Local functions
    function plotTS(v)
        % Plot timeseries
        info = getInfo();
        
        times = getTimes();
        
        plot(times, v, 'LineWidth', info.plotting.lineWidth);
        setTimeAxis();
        setFontSize();
        grid('on');
        box('on');
    end
end

