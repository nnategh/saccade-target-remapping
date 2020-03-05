% Pairwise distance

close('all');
clear();
clc();

filename = './assets/results/output-max.mat';

load(filename, 'W');
% W = W(:, :, 1:200); % `fix`
W = mean(W, 3); % mean over `time` dimension
W = W'; % [neurnon, location]

% pca
[~, W, ~, ~, V] = pca(W);
V = cumsum(V);
ind = find(V > 90, 1);



createFigure('PCA');

for i=1:80

m = W(:, 1:i);
% scatter3(W(:, 1), W(:, 2), W(:, 3), 'filled');

% W = W(:, 1:2);
% scatter(W(:, 1), W(:, 2), 'filled');

out(i)=nanmean(pdist(m));
end



% createFigure('Pairwise Distance');
% 
% histogram(pdist(W), 'Normalization', 'probability');
% 
% title('Pairwise distance between probe locations');
% xlabel('distance (probe)');
% ylabel('probability (unit)');
% 
% yticks(0:0.05:1);
% ylim([0, 0.5]);
% 
% set(gca, ...
%     'FontSize', 18, ...
%     'YGrid', 'on');
