%计算gain帧间预测系数，并计算残差
clear all;
load('../trainData/Gain.mat'); %Gain,本身已经是对数形式
[row, col] = size(Gain);
a = zeros(1,2);%帧间预测系数
% 0.9944    0.9944
N = size(Gain,1);%总帧数量

Gain(1,:) = [64.5440 64.5571];%第一帧用固定值
%限定在5~87dB，（标量量化10~77dB）
for n = 1:N
    for i = 1:2
        if Gain(n,i) < 5
            Gain(n,i) = 5;
        elseif Gain(n,i) > 87
            Gain(n,i) = 87;
        end
    end
end

%计算预测系数
sum_temp = zeros(1,2);
for n = 2:N
    for i = 1:2
        sum_temp(i) =  sum_temp(i)+Gain(n-1,i)*Gain(n,i);
    end
end
a(1) = sum_temp(1)/sum(Gain(:,1).^2);
a(2) = sum_temp(2)/sum(Gain(:,2).^2);

%计算预测值
gain_pre = zeros(row, col);
gain_pre(1,:) = Gain(1,:);
for n = 2:N
    for i = 1:2
        gain_pre(n,i) = a(i)*Gain(n-1,i);
    end
end

%计算残差
gain_res = Gain - gain_pre;
save('gain_res.mat','gain_res');

%恢复
gain_restor = zeros(row, col);
gain_restor(1,:) = [64.5440 64.5571];%第一帧用固定值
for n = 2:N
    for i = 1:2
        gain_restor(n,i) = a(i)*gain_restor(n-1,i) + gain_res(n,i);
    end
end

%误差校验
gain_err = Gain - gain_restor;
maxErr = max(abs(gain_err));
MaxErrValue = 1.0e-10;
if (maxErr(1)>MaxErrValue)||(maxErr(2)>MaxErrValue)
    error('larger than %e',MaxErrValue);
end
