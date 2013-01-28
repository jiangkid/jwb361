function [ gainQ ] = gainVQ( gain, mode )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global gainCB_9b gainCB_65_6 gainCB_65_5 gainCB_76_7 gainCB_76_6;
superSize = size(gain, 1);
if superSize ~= 4
    err('bandPass size ~= 4');
end

%concatenation
gainData(1:2) = gain(1,:);
gainData(3:4) = gain(2,:);
gainData(5:6) = gain(3,:);
gainData(7:8) = gain(4,:);

%Vector Quantization
switch mode
    case {MODE1, MODE2} 
        gainQ = gainMSVQ(gainData, gainCB_76_7, gainCB_76_6);
%         %stage 1
%         distance = pdist2(gainData, gainCB_76_7);
%         [value, idx] = min(distance);
%         gainQ(1) = idx;
%         residStage1 = gainData - gainCB_76_7(idx,:);
%         %stage 2
%         distance = pdist2(residStage1, gainCB_76_6);
%         [value, idx] = min(distance);
%         gainQ(2) = idx;
    case {MODE3, MODE4, MODE5}
        gainQ = gainMSVQ(gainData, gainCB_65_6, gainCB_65_5);
%         %stage 1
%         distance = pdist2(gainData, gainCB_65_6);
%         [value, idx] = min(distance);
%         gainQ(1) = idx;
%         residStage1 = gainData - gainCB_65_6(idx,:);
%         %stage 2
%         distance = pdist2(residStage1, gainCB_65_5);
%         [value, idx] = min(distance);
%         gainQ(2) = idx;
    case MODE6        
        distance = pdist2(gainData, gainCB_9b);
        [value, idx] = min(distance);
        gainQ = idx;
end
end

