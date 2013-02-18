function [ gainQ ] = gainVQ( gain, mode )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global gainCB_9b gainCB_65_6 gainCB_65_5 gainCB_76_7 gainCB_76_6;
superSize = size(gain, 1);
if superSize ~= 8
    err('bandPass size ~= 8');
end

%concatenation
gainData(1:2) = gain(1,:);
gainData(3:4) = gain(2,:);
gainData(5:6) = gain(3,:);
gainData(7:8) = gain(4,:);
gainData(9:10) = gain(5,:);
gainData(11:12) = gain(6,:);
gainData(13:14) = gain(7,:);
gainData(15:16) = gain(8,:);

%Vector Quantization
switch mode
    case MODE1
        gainQ = gainMSVQ(gainData, gainCB_76_7, gainCB_76_6);
    case {MODE2, MODE3}
        gainQ = gainMSVQ(gainData, gainCB_65_6, gainCB_65_5);
    case MODE4        
        distance = pdist2(gainData, gainCB_9b);
        [value, idx] = min(distance);
        gainQ = idx;
end
end

