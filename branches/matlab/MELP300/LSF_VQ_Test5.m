%8帧联合、原始数据矢量量化
clear all;
Error_All = 0;
% melp_init;
melp300_init;
global LSF_CB_31_s1 LSF_CB_31_s2 LSF_CB_31_s3 LSF_CB_31_s4;%31b=10+8+8+7
load('./data_org2.mat');
lsf_all = lsf_org;
% lpc_all = lpc_org;
% load('./trainData/lsf_testData.mat'); %lsf_all
% lsf_all = lsf_all'.*4000/pi;
% load('./trainData/lpc_all.mat'); %lpc_all
frameSize = 8;%8帧
frameNum = size(lsf_all,1);
superNum = fix(frameNum/frameSize);
SD = zeros(superNum*frameSize,1);
count = 0;
for frameIdx = 1:superNum
    LSF = lsf_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
%     lpcSuper = lpc_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
%     %calculate weight
    weight = ones(1,80);
%     for i=1:8
%         w = zeros(1, 10);
%         f = LSF(i,:);
%         lpcs = lpcSuper(i,:);
%         for j=1:10
%             w(j)=1+exp(-1i*f(j)*(1:10))*lpcs';
%         end
%         w=abs(w).^2;
%         w=w.^(-0.3);
%         w(9)=w(9)*0.64;
%         w(10)=w(10)*0.16;
%         weight((i-1)*10+1:i*10) = w;
%     end
%     
    LSF_VQ_Data = zeros(1,80);
    for i=1:8
        LSF_VQ_Data((i-1)*10+1:i*10) = LSF(i,:);
    end    
%     LSF_Q = LSF_VQ_new( lpcSuper, LSF, 4 );
    LSF_Q = LSF_4SVQ(LSF_VQ_Data, weight, LSF_CB_31_s1, LSF_CB_31_s2, LSF_CB_31_s3, LSF_CB_31_s4);
%    LSF_decode = LSF_VQ_new_d( LSF_Q, 4 );
     LSF_d = MSVQ_d(LSF_CB_31_s1,LSF_Q(1),LSF_CB_31_s2,LSF_Q(2),LSF_CB_31_s3,LSF_Q(3),LSF_CB_31_s4,LSF_Q(4));
    
    LSF_decode = zeros(8,10);
    for i=1:8
        LSF_decode(i,:) = LSF_d((i-1)*10+1:i*10);
    end
    
    for i = 1:8
        count = count+1;
        SD(count) = spectral_distortion(LSF_decode(i,:)*pi/4000,LSF(i,:)*pi/4000);
    end
    
end
disp(mean(SD));
hist(SD,100);
