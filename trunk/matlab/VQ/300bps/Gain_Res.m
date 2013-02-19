%����gain֡��Ԥ��ϵ����������в�
clear all;
load('../trainData/Gain.mat'); %Gain,�����Ѿ��Ƕ�����ʽ
[row, col] = size(Gain);
a = zeros(1,2);%֡��Ԥ��ϵ��
% 0.9944    0.9944
N = size(Gain,1);%��֡����

Gain(1,:) = [64.5440 64.5571];%��һ֡�ù̶�ֵ
%�޶���5~87dB������������10~77dB��
for n = 1:N
    for i = 1:2
        if Gain(n,i) < 5
            Gain(n,i) = 5;
        elseif Gain(n,i) > 87
            Gain(n,i) = 87;
        end
    end
end

%����Ԥ��ϵ��
sum_temp = zeros(1,2);
for n = 2:N
    for i = 1:2
        sum_temp(i) =  sum_temp(i)+Gain(n-1,i)*Gain(n,i);
    end
end
a(1) = sum_temp(1)/sum(Gain(:,1).^2);
a(2) = sum_temp(2)/sum(Gain(:,2).^2);

%����Ԥ��ֵ
gain_pre = zeros(row, col);
gain_pre(1,:) = Gain(1,:);
for n = 2:N
    for i = 1:2
        gain_pre(n,i) = a(i)*Gain(n-1,i);
    end
end

%����в�
gain_res = Gain - gain_pre;
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
gain_err = Gain - gain_restor;
maxErr = max(abs(gain_err));
MaxErrValue = 1.0e-10;
if (maxErr(1)>MaxErrValue)||(maxErr(2)>MaxErrValue)
    error('larger than %e',MaxErrValue);
end
