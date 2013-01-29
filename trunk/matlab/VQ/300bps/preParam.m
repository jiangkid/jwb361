%计算LSF帧间帧内预测系数
load('../trainData/lsf_all.mat'); %lsf_all
lsf_mean = [0.1897	0.3640	0.6313	0.9681	1.2868	1.6050	1.9230	2.2065	2.5305	2.8074];
w = lsf_all';
N = size(w,1);%总帧数量
for i = 1:N
    w(i,:) = w(i,:) - lsf_mean;
end
%w = w.*4000/pi;
%帧间、帧内预测
a = zeros(1,10);%帧内预测系数
%0   -0.2500   -0.5487   -0.6120   -0.7338   -0.6005   -0.5978   -0.4876   -0.4137   -0.1922
b = zeros(1,10);%帧间预测系数
%0.7961    0.7675    0.9341    1.0192    1.2519    1.1503    1.2330    1.0183    0.9311    0.7360
a(1) = 0;
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

%只做帧间预测
aa = zeros(1,10);%帧间预测系数
%0.7961    0.7343    0.7236    0.7834    0.8001    0.7799    0.7592    0.7084    0.7195    0.6328
sum_temp = zeros(1,10);
for i = 1:10
    for n = 2:N
        sum_temp(i) =  sum_temp(i)+w(n-1,i)*w(n,i);
    end
end
for i = 1:10
    aa(i) = sum_temp(i)/sum(w(:,i).^2);
end