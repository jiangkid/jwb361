%–≈∫≈ª÷∏¥/MFCC”Ô“Ù÷ÿΩ®≤‚ ‘
clear all;
J = [70, 60, 50, 40, 30];
PESQ_all = zeros(10, 5);
for i = 1: 5
    for k = 1: 10        
        PESQ_all(k, i) = mfcc2signal('part2.wav',J(i));
    end
end
