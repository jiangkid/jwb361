function [ mode ] = modeDeterm( bandPass )
%modeDeterm, 编解码模式判别
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE5 MODE6 MODE_DATA;
temp1 = size(bandPass, 1);
if temp1 ~= 4
    err('bandPass size ~= 4');
end
UV = zeros(1, 4);
for idx = 1:4
    VBP1 = bandPass(idx, 1);
    if VBP1 > 0.6
        UV(idx) = 1;
    else
        UV(idx) = 0;
    end
end

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

