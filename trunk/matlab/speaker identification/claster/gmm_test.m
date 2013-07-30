clear;
close all;
% X = [0.5*randn(100,2)+[2*ones(100,1),-2*ones(100,1)]; randn(100,2)-ones(100,2);randn(100,2)+ones(100,2)];
load('X.mat');

%%%%%%%%采用matlab系统函数生成GMM模型%%%%%%%
options = statset('Display', 'final');
obj = gmdistribution.fit(X, 3, 'Options', options, 'CovType', 'diagonal', 'Regularize', 1e-15);
%35 iterations, log-likelihood = -1002.28

idx = cluster(obj,X);
figure(1);
hold on;

plot(obj.mu(1,1),obj.mu(1,2), 'r*');
plot(X(idx==1,1),X(idx==1,2), 'r.');

plot(obj.mu(2,1),obj.mu(2,2), 'g*');
plot(X(idx==2,1),X(idx==2,2), 'g.');

plot(obj.mu(3,1),obj.mu(3,2), 'b*');
plot(X(idx==3,1),X(idx==3,2), 'b.');

hold off;

%%%%%%%%采用gmm函数函数生成GMM模型%%%%%%%

K = 3;
[IDX, C]  = kmeans(X, 3);%先kmeans聚类，!!!使用voicebox应注意kmeans重名问题!!!

[Px, model] = gmm(X, C);%再GMM聚类
%508 iterate, log-likelihood: -1002.21

[value, idx] = max(Px, [], 2);

% plot(X(idx==1,1),X(idx==1,2), '.');
figure(2);

hold on;

plot(model.Miu(1,1),model.Miu(1,2), 'r*');
plot(X(idx==1,1),X(idx==1,2), 'r.');

plot(model.Miu(2,1),model.Miu(2,2), 'g*');
plot(X(idx==2,1),X(idx==2,2), 'g.');

plot(model.Miu(3,1),model.Miu(3,2), 'b*');
plot(X(idx==3,1),X(idx==3,2), 'b.');

hold off;
