%MELP600 4帧7-6两级 增益码本训练
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

stage1_b = 7;
stage2_b = 6;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);

%stage1, train with origin signal
gainCB_7b = codeBookTrain(train_signal, stage1_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), gainCB_7b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - gainCB_7b(idx,:);    
end
disp('gain_7_6b stage1 completed');

%stage2, train with residual of stage1
gainCB_6b = codeBookTrain(residStage1, stage2_b);
save('gainCB_7_6b.mat', 'gainCB_7b', 'gainCB_6b');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), gainCB_6b);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - gainCB_6b(idx,:);  
end
disp('gain_7_6b completed');
save('gain_7_6b.mat');
