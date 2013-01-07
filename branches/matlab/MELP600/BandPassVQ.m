function [ bandPassQ ] = BandPassVQ ( bandPass )
%BandPassVQ，子带浊音强度矢量量化
%   Detailed explanation goes here
global BandPassCB_5b;
superSize = size(bandPass, 1);
if superSize ~= 4
    err('bandPass size ~= 4');
end
weight = [1.0 1.0 0.7 0.4 0.1];
BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];

%pre-prosess
tempData = zeros(superSize, 5);
for i=1:superSize
    distance = zeros(4,1);
    for j=1:4
        distance(j) = sqrt(sum(((bandPass(i,:)-BandPassCons(j,:)).*weight).^2));
    end
    [value, idx] = min(distance);
    tempData(i,:) = BandPassCons(idx,:);
end

%concatenation
bandPassData(1:5) = tempData(1,:);
bandPassData(6:10) = tempData(2,:);
bandPassData(11:15) = tempData(3,:);
bandPassData(16:20) = tempData(4,:);

%Vector Quantization
distance = pdist2(bandPassData, BandPassCB_5b);
[value, idx] = min(distance);
bandPassQ = idx;

end

