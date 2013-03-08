function [ gainQ ] = gainVQ( gain, mode )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4;
global gainCB_8b gainCB_9b gainCB_76_7 gainCB_76_6;
[row, col] = size(gain);
if row ~= 8
    err('row ~= 8');
end

%限定在5~87dB，（标量量化10~77dB）
for n = 1:row
    for i = 1:2
        if gain(n,i) < 5
            gain(n,i) = 5;
        elseif gain(n,i) > 87
            gain(n,i) = 87;
        end
    end
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
    case {MODE2}        
        distance = pdist2(gainData, gainCB_9b);
        [value, idx] = min(distance);
        gainQ = idx;
    case {MODE3,MODE4}
        distance = pdist2(gainData, gainCB_8b);
        [value, idx] = min(distance);
        gainQ = idx;
end
end

