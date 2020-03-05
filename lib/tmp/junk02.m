close('all');
clear();
clc();

% filename = './assets/results/output-max.mat';
% filename = './assets/results/output-mean.mat';
% filename = './assets/results/output-max-180.mat';
filename = './assets/results/output.mat';
load(filename, 'fixcorr');

tmin = -540;
tmax = 540;
lineWidth = 4;

tlim = [tmin, tmin + 200, 0, 30, tmax];
times = tmin:tmax;

createFigure('Location Sensitivity');

plot(times, fixcorr, 'LineWidth', lineWidth);
    
title('MAX');

xlabel('time from saccade onset (ms)');
xticks(unique([tmin, tlim, tmax]));
xlim([tmin, tmax]);

ylabel('correlation (unit)');
yticks(0:0.1:0.5)
ylim([0, 0.5]);

grid('on');
box('on');

set(gca, 'FontSize', 18);

saveas(gcf, 'max.png');