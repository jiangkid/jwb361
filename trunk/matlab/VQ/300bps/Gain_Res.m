%����gain֡��Ԥ��ϵ����������в�
clear all;
load('../trainData/Gain.mat'); %Gain,�����Ѿ��Ƕ�����ʽ
a = zeros(1,2);%֡��Ԥ��ϵ��
% 0.9944    0.9944
N = size(Gain,1);%��֡����
sum_temp = zeros(1,2);
for i = 1:2
    for n = 2:N
        sum_temp(i) =  sum_temp(i)+Gain(n-1,i)*Gain(n,i);
    end
end
for i = 1:2
    a(i) = sum_temp(i)/sum(Gain(:,i).^2);
end

gain_res = Gain;
for n = 2:N
    gain_res(n,:) = a(i)*Gain(n-1,:);
end
save('gain_res.mat','gain_res');