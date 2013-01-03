%MELP600 4帧8bits 基音周期码本训练
clear all;
load('../trainData/pitch_all.mat'); %pitch_all
%四帧联合训练
comb = 4;
[len_temp, dimen_temp] = size(pitch_all);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

for i=1:length    
    train_signal(i,1:2) = pitch_all(comb*i-3, :);
    train_signal(i,3:4) = pitch_all(comb*i-2, :);
    train_signal(i,5:6) = pitch_all(comb*i-1, :);
    train_signal(i,7:8) = pitch_all(comb*i, :);
end

stage1_b = 8;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);

%stage1, train with origin signal
pitchCB_8b = codeBookTrain(train_signal, stage1_b);
save('pitchCB_8b.mat', 'pitchCB_8b');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), pitchCB_8b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - pitchCB_8b(idx,:);    
end
disp('pitch_8b completed');
save('pitch_8b.mat');

