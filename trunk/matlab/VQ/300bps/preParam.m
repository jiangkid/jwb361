%����LSF֡��֡��Ԥ��ϵ��
load('../trainData/lsf_all.mat'); %lsf_all
w = lsf_all';
N = size(w,1);%��֡����
a = zeros(1,10);%֡��Ԥ��ϵ��
b = zeros(1,10);%֡��Ԥ��ϵ��
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