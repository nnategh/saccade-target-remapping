close('all');
clear();
clc();

b0 = 1;
b1 = 2;
n = 100;

x = linspace(0, 10, n);
x = randn(1, n) * 10;
y = b0 + b1 * (x .^ 2) + randn(1, n);

mdl = fitlm(x, y, 'y ~ X1 ^ 2');
b0_ = mdl.Coefficients{1, 1};
b1_ = mdl.Coefficients{2, 1};
y_ = b0_ + b1_ * x;


scatter(x, y, 'filled');
hold('on');
plot(x, y_, 'Color', [1, 0, 0], 'LineStyle', '--', 'LineWidth', 2);

disp(mdl);