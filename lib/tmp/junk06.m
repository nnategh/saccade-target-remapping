close('all');
clear();
clc();

filename = './assets/results/output-max.mat';

load(filename, 'W');
W = W(:, :, 1:200);
W = mean(W, 3);
W = W';

[~, W] = pca(W);

W = W(:, 1:10);

disp(V);