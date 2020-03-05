clear();
clc();

rows = 1;
cols = 2;
fontSize = 18;
filename = './assets/results-smm-response/output.mat';


load(filename, 'W'); % number[neuron, location, time]

tidx1 = msToIndex(0:100);
tidx2 = msToIndex(101:201);

D = abs(W(:, :, tidx1) - W(:, :, tidx2));
D = squeeze(mean(D, 1)); % number[location, time]

% plot
createFigure('Differenct bewteen peri- and post-saccadic');

% surf
subplot(rows, cols, 1);
surf(D);
view([0, 90]);

shading('interp');
c = colorbar();
c.Limits = [0, 0.31];
c.Ticks = 0:0.1:1;
c.Label.String = 'Probability of spike (unit)';

xlabel('time from sac onset (ms)');
ylabel('location (probe)');

set(gca, 'FontSize', fontSize);

axis('tight');

% grid
G = reshape(squeeze(mean(D, 2)), 9, 9);
G = G';
% G = flipud(G);

subplot(rows, cols, 2);
surf(G);
view([0, 90]);

shading('interp');
c = colorbar();
c.Limits = [0, 0.31];
c.Ticks = 0:0.1:1;
c.Label.String = 'Probability of spike (unit)';

xlabel('x (probe)');
ylabel('y (probe)');

set(gca, 'FontSize', fontSize);

axis('tight');

% plotGrid(G);


saveFigure('diff-peri-post');

