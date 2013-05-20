function [ LSF_Q ] = LSF_VQ1( lpcSuper, LSF, mode )
%LSF_VQ Summary of this function goes here
% f: lpc
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global LSF_CB_32_s1 LSF_CB_32_s2 LSF_CB_32_s3 LSF_CB_32_s4;%32b=9+8+8+7
global LSF_CB_30_s1 LSF_CB_30_s2 LSF_CB_30_s3 LSF_CB_30_s4;%30b=9+8+7+6
global LSF_CB_36_s1 LSF_CB_36_s2 LSF_CB_36_s3 LSF_CB_36_s4;%36b=10+9+9+8
superSize = size(LSF, 1);
if superSize ~= 4
    error('bandPass size ~= 4');
end
%concatenation
LSFData(1:10) = LSF(1,:);
LSFData(11:20) = LSF(2,:);
LSFData(21:30) = LSF(3,:);
LSFData(31:40) = LSF(4,:);

% LSFData = LSFData/4000 * (2^15);%归一化,Q15
% LSF_Q = melp_matlab(11, LSFData, mode); 
% return;%验证对应C算法

%calculate weight
weight = zeros(4,10);
for i=1:4
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
ww(1:10) = weight(1,:);
ww(11:20) = weight(2,:);
ww(21:30) = weight(3,:);
ww(31:40) = weight(4,:);

%Vector Quantization
switch mode
    case MODE1
        LSF_Q = LSF_4SVQ(LSFData, ww, LSF_CB_36_s1, LSF_CB_36_s2, LSF_CB_36_s3, LSF_CB_36_s4);
    case {MODE2, MODE3, MODE4, MODE5}
        LSF_Q = LSF_4SVQ(LSFData, ww, LSF_CB_30_s1, LSF_CB_30_s2, LSF_CB_30_s3, LSF_CB_30_s4);
    case MODE6
        LSF_Q = LSF_4SVQ(LSFData, ww, LSF_CB_32_s1, LSF_CB_32_s2, LSF_CB_32_s3, LSF_CB_32_s4);
end
end

