function [ LSF_Q ] = LSF_VQ( lpcSuper, LSF, mode )
%LSF_VQ Summary of this function goes here
% f: lpc
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global LSF_CB_753_7 LSF_CB_753_5 LSF_CB_753_3;%15bit
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
superSize = size(LSF, 1);
if superSize ~= 4
    error('bandPass size ~= 4');
end

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
ww(1,1:10) = weight(1,:);
ww(1,11:20) = weight(2,:);
ww(2,1:10) = weight(3,:);
ww(2,11:20) = weight(4,:);

%concatenation
LSFData1(1:10) = LSF(1,:);
LSFData1(11:20) = LSF(2,:);
LSFData2(1:10) = LSF(3,:);
LSFData2(11:20) = LSF(4,:);

%Vector Quantization
switch mode
    case MODE1
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
    case {MODE2, MODE3, MODE4, MODE5}
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_753_7, LSF_CB_753_5, LSF_CB_753_3);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_753_7, LSF_CB_753_5, LSF_CB_753_3);
    case MODE6
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, ww(1,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, ww(2,:), LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
end
end

