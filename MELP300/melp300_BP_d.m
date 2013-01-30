function [ bandPass ] = melp300_BP_d( bandPassQ )
%melp300_BP_d Summary of this function goes here
%   Detailed explanation goes here
global BandPassCB_5b;
% weight = [1.0 1.0 0.7 0.4 0.1];
% BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
tempData(1,:) = BandPassCB_5b(bandPassQ, 1:5);
tempData(2,:) = BandPassCB_5b(bandPassQ, 6:10);
tempData(3,:) = BandPassCB_5b(bandPassQ, 11:15);
tempData(4,:) = BandPassCB_5b(bandPassQ, 16:20);
% bandPass = zeros(4, 5);
% for i=1:4
%     distance = pdist2(tempData(i,:), BandPassCons);
%     [value, idx] = min(distance);
%     bandPass(i, :) = BandPassCons(idx,:);
% end
bandPass = tempData;
end

