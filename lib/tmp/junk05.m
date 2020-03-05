close('all');
clear();
clc();

filename = './assets/results/output-max.mat';

load(filename, 'W');
W = mean(W, 3);
W = W';

m = mean(W, 2);

n = size(W, 1);
d = zeros(n, 1);
for i = 1:n
    d(i) = norm(W(i, :) - m);
end

fprintf('Mean: %.3g\n', mean(d));
fprintf('STD:  %.3g\n', std(d));