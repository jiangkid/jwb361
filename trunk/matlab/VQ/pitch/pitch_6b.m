%MELP600 4帧6bits 基音周期码本训练
clear all;
load('../trainData/pitch_all.mat'); %pitch_all
%四帧联合训练
comb = 4;
[len_temp, dimen_temp] = size(pitch_all);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

pitch_all(len_temp) = pitch_all(len_temp-1);%最后一帧为0
pitch_all = log10(pitch_all);%对数

for i=1:length    
    train_signal(i,1) = pitch_all(comb*i-3, :);
    train_signal(i,2) = pitch_all(comb*i-2, :);
    train_signal(i,3) = pitch_all(comb*i-1, :);
    train_signal(i,4) = pitch_all(comb*i, :);
end

stage1_b = 6;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);

%stage1, train with origin signal
pitchCB_6b = codeBookTrain(train_signal, stage1_b);
save('pitchCB_6b.mat', 'pitchCB_6b');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), pitchCB_6b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - pitchCB_6b(idx,:);    
end
disp('pitch_6b completed');
save('pitch_6b.mat');

