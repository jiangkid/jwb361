%计算LSF帧间帧内预测系数
load('../trainData/lsf_all.mat'); %lsf_all
w = lsf_all';
N = size(w,1);%总帧数量
a = zeros(1,10);%帧内预测系数
b = zeros(1,10);%帧间预测系数
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