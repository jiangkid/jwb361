%计算LSF帧间帧内预测系数，并计算残差
clear all;
load('../trainData/lsf_all.mat'); %lsf_all
lsf_mean = [0.1897	0.3640	0.6313	0.9681	1.2868	1.6050	1.9230	2.2065	2.5305	2.8074];
w = lsf_all';
N = size(w,1);%总帧数量
[row, col] = size(w);

w(1,1) = 0.1897;%第一帧第一维用固定值
%去均值
for i = 1:N
    w(i,:) = w(i,:) - lsf_mean;
end

%帧间、帧内联合预测，传递误差太大！原因未知
a = zeros(1,10);%帧内预测系数
%0   -0.2500   -0.5487   -0.6120   -0.7338   -0.6005   -0.5978   -0.4876   -0.4137   -0.1922
b = zeros(1,10);%帧间预测系数
%0.7961    0.7675    0.9341    1.0192    1.2519    1.1503    1.2330    1.0183    0.9311    0.7360
temp = 0;
for n = 2:N
    temp =  temp+w(n-1,1)*w(n,1);
end
b(1) = temp/sum(w(:,1).^2);
for i = 2:10
    A = sum(w(:,i-1).^2);
    B = sum(w(:,i).^2);
    C = sum(w(:,i).*w(i-1));
    D = 0;
    E = 0;
    for n = 2:N
        D = D+w(n-1,i)*w(n,i);
        E = E+w(n-1,i)*w(n,i-1);
    end
    a(i) = (B*C-D*E)/(A*B-E*E);
    b(i) = (A*D-C*E)/(A*B-E*E);
end

%计算预测值
lsf_pre = zeros(row, col);
lsf_pre(1,1) = w(1,1);
%第一帧，只做帧内预测
for i = 2:10
    lsf_pre(1,i) = a(i)*w(1,i-1);
end
%向量第一维，只做帧间预测
for n = 2:N
    lsf_pre(n,1) = b(1)*w(n-1,1);
end
%其他，帧内、帧间预测
for n = 2:N
    for i = 2:10
        lsf_pre(n,i) = a(i)*w(n,i-1) + b(i)*w(n-1,i);
    end
end

%计算残差
lsf_res = w - lsf_pre;
save('lsf_res.mat','lsf_res');

%恢复
lsf_restor = zeros(row, col);
% lsf_restor(1,1) = 0.1897;%第一帧第一维用固定值
%第一帧
for i = 2:10
    lsf_restor(1,i) = a(i)*lsf_restor(1,i-1) + lsf_res(1,i);
end
%第一维
for n = 2:N
    lsf_restor(n,1) = b(1)*lsf_restor(n-1,1) + lsf_res(n,1);
end
%其他
for n = 2:N
    for i = 2:10
        lsf_restor(n,i) = a(i)*lsf_restor(n,i-1) + b(i)*lsf_restor(n-1,i) + lsf_res(n,i);
    end
end

%误差校验
lsf_err = w - lsf_restor;
maxErr = max(abs(lsf_err));
MaxErrValue = 1.0e-10;
for i = 1:10
    if maxErr(i)>MaxErrValue
        error('larger than %e',MaxErrValue);
    end
end
