%����LSF֡��֡��Ԥ��ϵ����������в�
clear all;
load('../trainData/lsf_all.mat'); %lsf_all
lsf_mean = [0.1897	0.3640	0.6313	0.9681	1.2868	1.6050	1.9230	2.2065	2.5305	2.8074];
w = lsf_all';
N = size(w,1);%��֡����
[row, col] = size(w);

w(1,:) = lsf_mean;%��һ֡�ù̶�ֵ
%ȥ��ֵ
for i = 1:N
    w(i,:) = w(i,:) - lsf_mean;
end

% %֡�ڡ�֡�䵥��
% %֡��Ԥ��
% a = zeros(1,10);%֡��Ԥ��ϵ��
% % 0    0.1391    0.4805    0.4998    0.7352    0.7239    0.9356    0.7675    0.6340    0.6726
% sum_temp = zeros(1,10);
% for i = 2:10
%     for n = 1:N
%         sum_temp(i) =  sum_temp(i)+w(n,i)*w(n,i-1);
%     end
% end
% for i = 1:10
%     a(i) = sum_temp(i)/sum(w(:,i).^2);
% end

%֡��Ԥ��
b = zeros(1,10);%֡��Ԥ��ϵ��
%0.7961    0.7343    0.7236    0.7834    0.8001    0.7799    0.7592    0.7084    0.7195    0.6328
sum_temp = zeros(1,10);
for i = 1:10
    for n = 2:N
        sum_temp(i) =  sum_temp(i)+w(n-1,i)*w(n,i);
    end
end
for i = 1:10
    b(i) = sum_temp(i)/sum(w(:,i).^2);
end

%����Ԥ��ֵ
lsf_pre = zeros(row, col);
lsf_pre(1,:) = w(1,:);
for n = 2:N
    for i = 1:10
        lsf_pre(n,i) = b(i)*w(n-1,i);
    end
end

%����в�
lsf_res = w - lsf_pre;
save('lsf_res.mat','lsf_res');

%�ָ�
lsf_restor = zeros(row, col);
% lsf_restor(1,:) = lsf_mean;%��һ֡�ù̶�ֵ
for n = 2:N
    for i = 1:10
        lsf_restor(n,i) = b(i)*lsf_restor(n-1,i) + lsf_res(n,i);
    end
end

%���У��
lsf_err = w - lsf_restor;
maxErr = max(abs(lsf_err));
MaxErrValue = 1.0e-10;
for i = 1:10
    if maxErr(i)>MaxErrValue
        error('larger than %e',MaxErrValue);
    end
end
