function [ LSF_Q ] = LSF_Pre_VQ( lpcSuper, LSF, mode )
%LSF_VQ Summary of this function goes here
% f: lpc
global MODE1 MODE2 MODE3 MODE4;
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_764_7 LSF_CB_764_6 LSF_CB_764_4;%17bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
global lsf_mean lsfPrevious;
b = [0.5547 0.2699 0.2090 0.3146 0.3382 0.3895 0.4183 0.3630 0.3724 0.2809];
[frameSize, col] = size(LSF);
if frameSize ~= 8
    error('frameSize ~= 8');
end
 
%去均值
for i = 1:frameSize
    LSF(i,:) = LSF(i,:) - lsf_mean;
end

%残差
lsf_res = zeros(frameSize, 10);
for i = 1:8
    lsf_res(i,:) = LSF(i,:) - b(i).*lsfPrevious;
end
lsfPrevious = LSF(frameSize,:);
    
%calculate weight
weight = zeros(8,10);
for i=1:8
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

%对残差进行矢量量化
%concatenation
LSFData1(1:10) = lsf_res(1,:);
LSFData1(11:20) = lsf_res(2,:);
LSFData1(21:30) = lsf_res(3,:);
LSFData1(31:40) = lsf_res(4,:);
LSFData2(1:10) = lsf_res(5,:);
LSFData2(11:20) = lsf_res(6,:);
LSFData2(21:30) = lsf_res(7,:);
LSFData2(31:40) = lsf_res(8,:);

%Vector Quantization
switch mode
    case MODE1
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
    case {MODE2}
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_764_7, LSF_CB_764_6, LSF_CB_764_4);
    case {MODE3,MODE4}
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
end

end

