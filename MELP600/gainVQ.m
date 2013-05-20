function [ gainQ ] = gainVQ( gain, mode )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global gainCB_9b gainCB_65_6 gainCB_65_5 gainCB_76_7 gainCB_76_6;
[row, col] = size(gain);
if row ~= 4
    err('row ~= 4');
end

%限定在6~80dB，（标量量化10~77dB）
for n = 1:row
    for i = 1:2
        if gain(n,i) < 6
            gain(n,i) = 6;
        elseif gain(n,i) > 80
            gain(n,i) = 80;
        end
    end
end
%concatenation
gainData(1:2) = gain(1,:);
gainData(3:4) = gain(2,:);
gainData(5:6) = gain(3,:);
gainData(7:8) = gain(4,:);

% gainData = gainData'*(2^8);%pitch Q8
% gainQ = melp_matlab(41, gainData, mode);
% return;%验证C算法
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

