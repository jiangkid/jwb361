%MELP600 4帧9bits 增益码本训练
clear all;
load('../trainData/Gain.mat'); %Gain
%四帧联合训练
comb = 4;
[len_temp, dimen_temp] = size(Gain);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

for i=1:length    
    train_signal(i,1:2) = Gain(comb*i-3, :);
    train_signal(i,3:4) = Gain(comb*i-2, :);
    train_signal(i,5:6) = Gain(comb*i-1, :);
    train_signal(i,7:8) = Gain(comb*i, :);
end
% 方法二
% train_signal(:,1:2) = Gain(1:4:length*comb,:);
% train_signal(:,3:4) = Gain(2:4:length*comb,:);
% train_signal(:,5:6) = Gain(3:4:length*comb,:);
% train_signal(:,7:8) = Gain(4:4:length*comb,:);

stage1_b = 9;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);

%stage1, train with origin signal
gainCB_9b = codeBookTrain(train_signal, stage1_b);
save('gainCB_9b.mat', 'gainCB_9b');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), gainCB_9b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - gainCB_9b(idx,:);    
end
disp('gain_9b completed');
save('gain_9b.mat');

