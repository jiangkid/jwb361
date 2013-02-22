%����gain֡��Ԥ��ϵ����������в�
clear all;
load('../trainData/gain_all.mat'); %�����Ѿ��Ƕ�����ʽ
[row, col] = size(gain_all);
a = zeros(1,2);%֡��Ԥ��ϵ��
% 0.9944    0.9944
N = size(gain_all,1);%��֡����

gain_all(1,:) = [64.5440 64.5571];%��һ֡�ù̶�ֵ
%�޶���5~87dB������������10~77dB��
for n = 1:N
    for i = 1:2
        if gain_all(n,i) < 5
            gain_all(n,i) = 5;
        elseif gain_all(n,i) > 87
            gain_all(n,i) = 87;
        end
    end
end

%����Ԥ��ϵ��
sum_temp = zeros(1,2);
for n = 2:N
    for i = 1:2
        sum_temp(i) =  sum_temp(i)+gain_all(n-1,i)*gain_all(n,i);
    end
end
a(1) = sum_temp(1)/sum(gain_all(:,1).^2);
a(2) = sum_temp(2)/sum(gain_all(:,2).^2);

%����Ԥ��ֵ
gain_pre = zeros(row, col);
gain_pre(1,:) = gain_all(1,:);
for n = 2:N
    for i = 1:2
        gain_pre(n,i) = a(i)*gain_all(n-1,i);
    end
end

%����в�
gain_res = gain_all - gain_pre;
save('gain_res.mat','gain_res');

%�ָ�
gain_restor = zeros(row, col);
gain_restor(1,:) = [64.5440 64.5571];%��һ֡�ù̶�ֵ
for n = 2:N
    for i = 1:2
        gain_restor(n,i) = a(i)*gain_restor(n-1,i) + gain_res(n,i);
    end
end

%���У��
gain_err = gain_all - gain_restor;
maxErr = max(abs(gain_err));
MaxErrValue = 1.0e-10;
if (maxErr(1)>MaxErrValue)||(maxErr(2)>MaxErrValue)
    error('larger than %e',MaxErrValue);
end
