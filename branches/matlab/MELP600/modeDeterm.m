function [ mode ] = modeDeterm( bandPass )
%modeDeterm, 编解码模式判别
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6 MODE_DATA;
superSize = size(bandPass, 1);
if superSize ~= 4
    error('bandPass size ~= 4');
end
% weight = [1.0 1.0 0.7 0.4 0.1];
BandPassCons = [0 0 0 0 0; 1 0 0 0 0; 1 1 1 0 0; 1 1 1 1 1];
%preprocess
for i=1:superSize
    if bandPass(i,1) < 0.6
        bandPass(i,:) = 0;
    else
        bandPass(i,1) = 1;
        for j = 2:5
            if bandPass(i, j) > 0.6
                bandPass(i, j) = 1;
            else
                bandPass(i, j) = 0;
            end
        end
        if bandPass(i, 2:5) == 0001
            bandPass(i, 2:5) = 0;
        end
    end
end
tempData = zeros(superSize, 5);
for i=1:superSize
    distance = zeros(4,1);
    for j=1:4
        distance(j) = sqrt(sum(((bandPass(i,:)-BandPassCons(j,:))).^2));
    end
    [value, idx] = min(distance);
    tempData(i,:) = BandPassCons(idx,:);
end

UV = tempData(:,1);
UV = UV';
% for idx = 1:4
%     VBP1 = bandPass(idx, 1);
%     if VBP1 > 0.6
%         UV(idx) = 1;
%     else
%         UV(idx) = 0;
%     end
% end

for mode_idx = 1:16
    if isequal(UV,MODE_DATA(mode_idx,:))
        if mode_idx == 1
            mode = MODE1;
        elseif 2 <= mode_idx && mode_idx <= 5
            mode = MODE2;
        elseif 6 <= mode_idx && mode_idx <= 9
            mode = MODE3;
        elseif 10 <= mode_idx && mode_idx <= 11
            mode = MODE4;
        elseif 12 <= mode_idx && mode_idx <= 15
            mode = MODE5;
        elseif 16 == mode_idx
            mode = MODE6;
        end
        break;
    end
end

end

