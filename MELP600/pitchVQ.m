function [ pitchQ ] = pitchVQ( pitch, mode )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6;
global  pitchCB_6b pitchCB_8b;
superSize = size(pitch, 1);
if superSize ~= 4
    err('bandPass size ~= 4');
end

%concatenation
pitchData  = log10(pitch');

%Vector Quantization
switch mode
    case MODE1
        pitchQ = 0;
    case MODE2
        distance = pdist2(pitchData, pitchCB_6b);
        [value, idx] = min(distance);
        pitchQ = idx;
    case {MODE3, MODE4, MODE5, MODE6}
        distance = pdist2(pitchData, pitchCB_8b);
        [value, idx] = min(distance);
        pitchQ = idx;
end
end

