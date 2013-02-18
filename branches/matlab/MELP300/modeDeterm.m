function [ mode ] = modeDeterm( bandPass )
%modeDeterm, �����ģʽ�б�
%   Detailed explanation goes here
global MODE1 MODE2 MODE3 MODE4 MODE_DATA;
superSize = size(bandPass, 1);
if superSize ~= 8
    error('bandPass size ~= 8');
end
% weight = [1.0 1.0 0.7 0.4 0.1];

UV = bandPass(:,1);
UV = UV';

V_Count1 = 0;%ǰ��֡
V_Count2 = 0;%���֡
for i = 1:4
    if UV(i) == 1
        V_Count1 = V_Count1+1;
    end
end
for i = 5:8
    if UV(i) == 1
        V_Count2 = V_Count2+1;
    end
end

if V_Count1+V_Count2 == 0
    mode = MODE1;
elseif V_Count1+V_Count2 == 1
    mode = MODE2;
elseif ((V_Count1==0) || (V_Count2==0))
    mode = MODE3;
else
    mode = MODE4;
end

end

