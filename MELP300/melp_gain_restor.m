function [gain] = melp_gain_restor(gain_res)
%»Ö¸´
a = [0.9944 0.9944];%Ö¡¼äÔ¤²âÏµÊý
gain = zeros(size(gain_res));
global gainRestorPre
for i = 1:2
    gain(1,i) = a(i)*gainRestorPre(i) + gain_res(1,i);
end
for n = 2:8
    for i = 1:2
        gain(n,i) = a(i)*gain(n-1,i) + gain_res(n,i);
    end
end
gainRestorPre = gain(8,:);

end