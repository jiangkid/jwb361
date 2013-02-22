%奇数帧用原始数据、偶数帧用预测残差
clear all;
Error_All = 0;
% melp_init;
melp300_init;
load('./codebook/LSF_CB_764b_org.mat');%LSF_CB_764_7_org, LSF_CB_764_6_org, LSF_CB_764_4_org

load('./trainData/lsf_all.mat'); %lsf_all
load('./trainData/lpc_all.mat'); %lpc_all
b = [0.7791 0.7043 0.7132 0.7859 0.8109 0.7875 0.7809 0.7028 0.6926 0.6300];%帧间预测系数
frameSize = 8;%8帧
frameNum = size(lsf_all,1);
SD = zeros(frameNum,1);
lsf_restor_all = zeros(frameNum,10);
count = 0;
superNum = fix(frameNum/frameSize);
for frameIdx = 1:superNum
    LSF = lsf_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    lpcSuper = lpc_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    
    %去均值
    for i = 1:frameSize
        LSF(i,:) = LSF(i,:) - lsf_mean;
    end
    
    %残差 2 4 6 8
    lsf_res = zeros(4, 10);
    for i = 1:4
        lsf_res(i,:) = LSF(2*i,:) - b.*LSF(2*i-1,:);
    end
    %原数据1 3 5 7
    lsf_org = LSF(1:2:end,:);
%     for i = 1:4
%         lsf_org(i,:) = lsf_org(i,:) + lsf_mean;%原数据加上均值
%     end
%     
    %calculate weight
    weight_res = zeros(4,10);
    for i=1:4
        w = zeros(1, 10);
        f = lsf_res(i,:);
        lpcs = lpcSuper(i,:);
        for j=1:10
            w(j)=1+exp(-1i*f(j)*(1:10))*lpcs';
        end
        w=abs(w).^2;
        w=w.^(-0.3);
        w(9)=w(9)*0.64;
        w(10)=w(10)*0.16;
        weight_res(i,:) = w;
    end
    
    ww_res(1,1:10) = weight_res(1,:);
    ww_res(1,11:20) = weight_res(2,:);
    ww_res(1,21:30) = weight_res(3,:);
    ww_res(1,31:40) = weight_res(4,:);
    weight = zeros(8,10);
    
    for i=1:4
        w = zeros(1, 10);
        f = lsf_org(i,:);
        lpcs = lpcSuper(i,:);
        for j=1:10
            w(j)=1+exp(-1i*f(j)*(1:10))*lpcs';
        end
        w=abs(w).^2;
        w=w.^(-0.3);
        w(9)=w(9)*0.64;
        w(10)=w(10)*0.16;
        weight(i,:) = w;
    end
    ww(1,1:10) = weight(1,:);
    ww(1,11:20) = weight(2,:);
    ww(1,21:30) = weight(3,:);
    ww(1,31:40) = weight(4,:);
    
    LSFData_res(1:10) = lsf_res(1,:);
    LSFData_res(11:20) = lsf_res(2,:);
    LSFData_res(21:30) = lsf_res(3,:);
    LSFData_res(31:40) = lsf_res(4,:);
    
    LSFData(1:10) = lsf_org(1,:);
    LSFData(11:20) = lsf_org(2,:);
    LSFData(21:30) = lsf_org(3,:);
    LSFData(31:40) = lsf_org(4,:);
    
    LSF_Q(1, :) = LSF_MSVQ(LSFData_res, ww_res(1,:), LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4);%残差
    LSF_Q(2, :) = LSF_MSVQ(LSFData, ww(1,:), LSF_CB_764_7_org, LSF_CB_764_6_org, LSF_CB_764_4_org);%原数据
    
    LSF_Data(1,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(1,1),LSF_CB_764_6,LSF_Q(1,2),LSF_CB_764_4,LSF_Q(1,3));%残差
    LSF_Data(2,:) = MSVQ_d(LSF_CB_764_7_org,LSF_Q(2,1),LSF_CB_764_6_org,LSF_Q(2,2),LSF_CB_764_4_org,LSF_Q(2,3));%原数据
    
    LSF_decode_res(1,:) = LSF_Data(1, 1:10);
    LSF_decode_res(2,:) = LSF_Data(1, 11:20);
    LSF_decode_res(3,:) = LSF_Data(1, 21:30);
    LSF_decode_res(4,:) = LSF_Data(1, 31:40);
    
    LSF_decode(1,:) = LSF_Data(2, 1:10);
    LSF_decode(2,:) = LSF_Data(2, 11:20);
    LSF_decode(3,:) = LSF_Data(2, 21:30);
    LSF_decode(4,:) = LSF_Data(2, 31:40);
    
%     %去均值
%     for i = 1:4
%         LSF_decode(i,:) = LSF_decode(i,:) - lsf_mean;
%     end
    
    %恢复
    lsf_restor_temp = zeros(4, 10);
    for i = 1:4
        lsf_restor_temp(i,:) = b.*LSF_decode(i,:) + LSF_decode_res(i,:);
    end
    lsf_restor = zeros(8, 10);
    lsf_restor(1:2:end,:) = LSF_decode;
    lsf_restor(2:2:end,:) = lsf_restor_temp;
    
    %加均值
    for i = 1:frameSize
        lsf_restor(i,:) = lsf_restor(i,:) + lsf_mean;
         LSF(i,:) = LSF(i,:) + lsf_mean;
    end
    for i = 1:frameSize
        for j=1:10
            if(lsf_restor(i,j)<=0) || (lsf_restor(i,j)>=4000)
                lsf_restor(i,j) = lsf_mean(j);
            end
        end
    end
    for i = 1:8
        count = count+1;
        lsf_restor_all(count,:) = lsf_restor(i,:);
    end    
end
%计算谱失真
for i=1:superNum*8
    SD(i,:) = spectral_distortion(lsf_restor_all(i,:)*pi/4000,lsf_all(i,:)*pi/4000);    
end
disp(mean(SD));
hist(SD,100);
