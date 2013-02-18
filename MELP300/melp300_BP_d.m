function [ bandPass ] = melp300_BP_d( bandPassQ )
%melp300_BP_d Summary of this function goes here
%   Detailed explanation goes here
global BandPassCB_5b;
tempData(1,:) = BandPassCB_5b(bandPassQ, 1:5);
tempData(2,:) = BandPassCB_5b(bandPassQ, 6:10);
tempData(3,:) = BandPassCB_5b(bandPassQ, 11:15);
tempData(4,:) = BandPassCB_5b(bandPassQ, 16:20);
tempData(5,:) = BandPassCB_5b(bandPassQ, 21:25);
tempData(6,:) = BandPassCB_5b(bandPassQ, 26:30);
tempData(7,:) = BandPassCB_5b(bandPassQ, 31:35);
tempData(8,:) = BandPassCB_5b(bandPassQ, 36:40);
bandPass = tempData;
end

