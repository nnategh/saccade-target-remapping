close('all');
clear();
clc();

n = 10;

X = makeData(n);
plotData(X);

theta = 45;
R = [cosd(theta), -sind(theta); sind(theta), cosd(theta)];
disp(R);

X = R * X';
X = X';
hold('on');
plotData(X);

[C, Y, V] = pca(X);
disp(C);
disp(Y);
disp(V);

Y = (inv(C) * X')';
disp(Y);

function X = makeData(n)
    X = [1:n; zeros(1, n)]';
end

function plotData(X)
    scatter(X(:, 1), X(:, 2), 'filled');
end