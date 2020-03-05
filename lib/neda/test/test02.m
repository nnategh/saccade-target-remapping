close('all');
clear();
clc();

b0 = 1;
b1 = 2;
b2 = 3;
n = 100;

x1 = randn(n, 1) * 10;
x2 = randn(n, 1) * 10;
y = b0 + b1 * x1 + b2 * x2 + randn(n, 1);

mdl = fitlm([x1, x2], y, 'VarNames', {'a', 'b', 'c'});
b0_ = mdl.Coefficients{1, 1};
b1_ = mdl.Coefficients{2, 1};
b2_ = mdl.Coefficients{3, 1};
y_ = b0_ + b1_ * x1 + b2_ * x2;


scatter3(x1, x2, y, 'filled');
hold('on');
line(x1, x2, y_, 'Color', [1, 0, 0], 'LineStyle', '--', 'LineWidth', 2);

mdl