clear all;
Error_All = 0;
% melp_init;
melp300_init;
load('./trainData/gain_all.mat'); %Gain,本身已经是对数形式
a = [0.9944 0.9944];%帧间预测系数
frameSize = 8;%8帧
frameNum = size(gain_all,1);
superNum = fix(frameNum/frameSize);
for frameIdx = 1:superNum
    gainData = gain_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    
    %限定在5~87dB，（标量量化10~77dB）
    for n = 1:frameSize
        for i = 1:2
            if gainData(n,i) < 5
                gainData(n,i) = 5;
            elseif gainData(n,i) > 87
                gainData(n,i) = 87;
            end
        end
    end    
    
    if 1 %对残差进行矢量量化 Error_All 7.5033e+007        
        %计算预测
        gain_predict = zeros(frameSize, 2);
        for i = 1:2
            gain_predict(1,i) = a(i)*gainLast(i);
        end
        gainLast = gainData(frameSize,:);
        for n = 2:frameSize
            for i = 1:2
                gain_predict(n,i) = a(i)*gainData(n-1,i);
            end
        end        
        %计算残差
        gain_res = gainData - gain_predict;
        gain_resVQ(1:2) = gain_res(1,:);
        gain_resVQ(3:4) = gain_res(2,:);
        gain_resVQ(5:6) = gain_res(3,:);
        gain_resVQ(7:8) = gain_res(4,:);
        gain_resVQ(9:10) = gain_res(5,:);
        gain_resVQ(11:12) = gain_res(6,:);
        gain_resVQ(13:14) = gain_res(7,:);
        gain_resVQ(15:16) = gain_res(8,:);
        
        gainQ = gainMSVQ(gain_resVQ, gainCB_65_6, gainCB_65_5);
        gainDecode = MSVQ_d(gainCB_65_6,gainQ(1),gainCB_65_5,gainQ(2));
        
        gain_res_decode(1,:) = gainDecode(1:2);
        gain_res_decode(2,:) = gainDecode(3:4);
        gain_res_decode(3,:) = gainDecode(5:6);
        gain_res_decode(4,:) = gainDecode(7:8);
        gain_res_decode(5,:) = gainDecode(9:10);
        gain_res_decode(6,:) = gainDecode(11:12);
        gain_res_decode(7,:) = gainDecode(13:14);
        gain_res_decode(8,:) = gainDecode(15:16);
        %恢复
        gain_restor = zeros(frameSize, 2);
        for i = 1:2
            gain_restor(1,i) = a(i)*gainRestorPre(i) + gain_res_decode(1,i);
        end
        for n = 2:8
            for i = 1:2
                gain_restor(n,i) = a(i)*gain_restor(n-1,i) + gain_res_decode(n,i);
            end
        end
        gainRestorPre = gain_restor(frameSize,:);
    else %对原始数据进行矢量量化 Error_All 1.2714e+006
        gain_resVQ(1:2) = gainData(1,:);
        gain_resVQ(3:4) = gainData(2,:);
        gain_resVQ(5:6) = gainData(3,:);
        gain_resVQ(7:8) = gainData(4,:);
        gain_resVQ(9:10) = gainData(5,:);
        gain_resVQ(11:12) = gainData(6,:);
        gain_resVQ(13:14) = gainData(7,:);
        gain_resVQ(15:16) = gainData(8,:);
        
        gainQ = gainMSVQ(gain_resVQ, gainCB_65_6, gainCB_65_5);
        gainDecode = MSVQ_d(gainCB_65_6,gainQ(1),gainCB_65_5,gainQ(2));
        
        gain_restor(1,:) = gainDecode(1:2);
        gain_restor(2,:) = gainDecode(3:4);
        gain_restor(3,:) = gainDecode(5:6);
        gain_restor(4,:) = gainDecode(7:8);
        gain_restor(5,:) = gainDecode(9:10);
        gain_restor(6,:) = gainDecode(11:12);
        gain_restor(7,:) = gainDecode(13:14);
        gain_restor(8,:) = gainDecode(15:16);
    end
    
    %误差计算
    gain_err = gainData - gain_restor;
    Error_All = Error_All + sum(sum(gain_err.^2));
end
disp(Error_All);