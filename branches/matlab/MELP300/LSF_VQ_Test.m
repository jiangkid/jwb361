%��ԭʼ���ݽ���ʸ������
clear all;
Error_All = 0;
% melp_init;
melp300_init;
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;
% load('./trainData/lsf_all.mat'); %lsf_all
% load('./trainData/lpc_all.mat'); %lpc_all
load('./test4_data.mat');
lsf_all = lsf_org;

frameSize = 8;%8֡
frameNum = size(lsf_all,1);
superNum = fix(frameNum/frameSize);
SD = zeros(superNum*frameSize,1);
count = 0;

for frameIdx = 1:superNum
    LSF = lsf_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    %     lpcSuper = lpc_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    
    ww = ones(2,40);
    
    LSFData1(1:10) = LSF(1,:);
    LSFData1(11:20) = LSF(2,:);
    LSFData1(21:30) = LSF(3,:);
    LSFData1(31:40) = LSF(4,:);
    LSFData2(1:10) = LSF(5,:);
    LSFData2(11:20) = LSF(6,:);
    LSFData2(21:30) = LSF(7,:);
    LSFData2(31:40) = LSF(8,:);
    
    LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
    LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
    
    LSF_Data(1,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(1,1),LSF_CB_754_5,LSF_Q(1,2),LSF_CB_754_4,LSF_Q(1,3));
    LSF_Data(2,:) = MSVQ_d(LSF_CB_754_7,LSF_Q(2,1),LSF_CB_754_5,LSF_Q(2,2),LSF_CB_754_4,LSF_Q(2,3));
    
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
disp(mean(SD));

% hist(SD,100);
