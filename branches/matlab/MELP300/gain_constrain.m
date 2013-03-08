clear all;
load('trainData.mat');
N = size(gain_all,1);
for n = 1:N
    for i = 1:2
        if gain_all(n,i) < 6
            gain_all(n,i) = 6;
        elseif gain_all(n,i) > 80
            gain_all(n,i) = 80;
        end
    end
end
save('trainData.mat','pitch_all','gain_all','vbp_all','lsf_all','lpc_all');
