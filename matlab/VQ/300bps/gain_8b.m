%MELP300 8帧8bits 增益码本训练
clear all;
load('./gain_res.mat'); %gain_res
%8帧联合训练
comb = 8;
[len_temp, dimen_temp] = size(gain_res);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

for i=1:length    
    train_signal(i,1:2) = gain_res(comb*i-7, :);
    train_signal(i,3:4) = gain_res(comb*i-6, :);
    train_signal(i,5:6) = gain_res(comb*i-5, :);
    train_signal(i,7:8) = gain_res(comb*i-4, :);
    train_signal(i,9:10) = gain_res(comb*i-3, :);
    train_signal(i,11:12) = gain_res(comb*i-2, :);
    train_signal(i,13:14) = gain_res(comb*i-1, :);
    train_signal(i,15:16) = gain_res(comb*i, :);
end

stage1_b = 8;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);

%stage1, train with origin signal
gainCB_8b = codeBookTrain(train_signal, stage1_b);
save('gainCB_8b.mat', 'gainCB_8b');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), gainCB_8b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - gainCB_8b(idx,:);    
end
disp('gain_8b completed');
save('gain_8b.mat');

