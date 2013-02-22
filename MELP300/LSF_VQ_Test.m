%对原始数据进行矢量量化
clear all;
Error_All = 0;
% melp_init;
melp300_init;
load('./trainData/lsf_all.mat'); %lsf_all
load('./trainData/lpc_all.mat'); %lpc_all
frameSize = 8;%8帧
frameNum = size(lsf_all,1);
SD = zeros(frameNum,1);
count = 0;
superNum = fix(frameNum/frameSize);
for frameIdx = 1:superNum
    LSF = lsf_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    lpcSuper = lpc_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    %calculate weight
    weight = zeros(8,10);
    for i=1:8
        w = zeros(1, 10);
        f = LSF(i,:);
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
    ww(2,1:10) = weight(5,:);
    ww(2,11:20) = weight(6,:);
    ww(2,21:30) = weight(7,:);
    ww(2,31:40) = weight(8,:);
    
    LSFData1(1:10) = LSF(1,:);
    LSFData1(11:20) = LSF(2,:);
    LSFData1(21:30) = LSF(3,:);
    LSFData1(31:40) = LSF(4,:);
    LSFData2(1:10) = LSF(5,:);
    LSFData2(11:20) = LSF(6,:);
    LSFData2(21:30) = LSF(7,:);
    LSFData2(31:40) = LSF(8,:);
    
    LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4);
    LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4);
    
    LSF_Data(1,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(1,1),LSF_CB_764_6,LSF_Q(1,2),LSF_CB_764_4,LSF_Q(1,3));
    LSF_Data(2,:) = MSVQ_d(LSF_CB_764_7,LSF_Q(2,1),LSF_CB_764_6,LSF_Q(2,2),LSF_CB_764_4,LSF_Q(2,3));
    
    LSF_decode(1,:) = LSF_Data(1, 1:10);
    LSF_decode(2,:) = LSF_Data(1, 11:20);
    LSF_decode(3,:) = LSF_Data(1, 21:30);
    LSF_decode(4,:) = LSF_Data(1, 31:40);
    LSF_decode(5,:) = LSF_Data(2, 1:10);
    LSF_decode(6,:) = LSF_Data(2, 11:20);
    LSF_decode(7,:) = LSF_Data(2, 21:30);
    LSF_decode(8,:) = LSF_Data(2, 31:40);
    
    for i = 1:8
        count = count+1;
        SD(count) = spectral_distortion(LSF_decode(i,:)*pi/4000,LSF(i,:)*pi/4000);
    end
    
end

