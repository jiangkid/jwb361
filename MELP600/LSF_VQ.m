function [ LSF_Q ] = LSF_VQ( LSF, mode )
%LSF_VQ Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global LSF_CB_753_7 LSF_CB_753_5 LSF_CB_753_3;%15bit
global LSF_CB_754_7 LSF_CB_754_5 LSF_CB_754_4;%16bit
global LSF_CB_765_7 LSF_CB_765_6 LSF_CB_765_5;%18bit
superSize = size(LSF, 1);
if superSize ~= 4
    err('bandPass size ~= 4');
end

%concatenation
LSFData1(1:10) = LSF(1,:);
LSFData1(11:20) = LSF(2,:);
LSFData2(1:10) = LSF(3,:);
LSFData2(11:20) = LSF(4,:);

%Vector Quantization
switch mode
    case MODE1
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, LSF_CB_765_7, LSF_CB_765_6, LSF_CB_765_5);
    case {MODE2, MODE3, MODE4, MODE5}
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, LSF_CB_753_7, LSF_CB_753_5, LSF_CB_753_3);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, LSF_CB_753_7, LSF_CB_753_5, LSF_CB_753_3);
    case MODE6
        LSF_Q(1, :) = LSF_MSVQ(LSFData1, LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
        LSF_Q(2, :) = LSF_MSVQ(LSFData2, LSF_CB_754_7, LSF_CB_754_5, LSF_CB_754_4);
end
end

