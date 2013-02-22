clear all;
load('gain_all.mat');
N = size(gain_all,1);
for n = 1:N
    for i = 1:2
        if gain_all(n,i) < 10
            gain_all(n,i) = 10;
        elseif gain_all(n,i) > 77
            gain_all(n,i) = 77;
        end
    end
end
save('gain_all.mat','gain_all');