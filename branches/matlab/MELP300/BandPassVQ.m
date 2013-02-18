function [ bandPassQ ] = BandPassVQ ( bandPass )
%BandPassVQ，子带浊音强度矢量量化
%   Detailed explanation goes here
global BandPassCB_5b;
superSize = size(bandPass, 1);
if superSize ~= 8
    error('bandPass size ~= 8');
end
weight = [1 1/2 1/4 1/16 1/32];
% weight = [1.0 1.0 0.7 0.4 0.1];
w = [weight,weight,weight,weight,weight,weight,weight,weight];
bandPass = BandPassConstrain(bandPass);

% BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
% 
% %pre-prosess
% tempData = zeros(superSize, 5);
% for i=1:superSize
%     distance = zeros(4,1);
%     for j=1:4
%         distance(j) = sqrt(sum(((bandPass(i,:)-BandPassCons(j,:)).*weight).^2));
%     end
%     [value, idx] = min(distance);
%     tempData(i,:) = BandPassCons(idx,:);
% end
%concatenation
bandPassData(1:5) = bandPass(1,:);
bandPassData(6:10) = bandPass(2,:);
bandPassData(11:15) = bandPass(3,:);
bandPassData(16:20) = bandPass(4,:);
bandPassData(21:25) = bandPass(5,:);
bandPassData(26:30) = bandPass(6,:);
bandPassData(31:35) = bandPass(7,:);
bandPassData(36:40) = bandPass(8,:);

%Vector Quantization
[value, bandPassQ] = GetMatch(bandPassData, BandPassCB_5b, w);

end

