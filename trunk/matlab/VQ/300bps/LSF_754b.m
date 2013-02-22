%MELP300码本训练
clear all;
load('./lsf_res.mat'); %lsf_res
%四帧联合训练
comb = 4;
[len_temp, dimen_temp] = size(lsf_res);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);
for i=1:length
    train_signal(i,1:10) = lsf_res(comb*i-3, :);
    train_signal(i,11:20) = lsf_res(comb*i-2, :);
	train_signal(i,21:30) = lsf_res(comb*i-1, :);
	train_signal(i,31:40) = lsf_res(comb*i, :);
end

stage1_b = 7;
stage2_b = 5;
stage3_b = 4;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, codebook_dimen);

%stage1, train with origin signal
LSF_CB_754_7 = codeBookTrain(train_signal, stage1_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), LSF_CB_754_7);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - LSF_CB_754_7(idx,:);    
end
disp('stage1 completed');

%stage2, train with residual of stage1
LSF_CB_754_5 = codeBookTrain(residStage1, stage2_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), LSF_CB_754_5);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - LSF_CB_754_5(idx,:);  
end
disp('stage2 completed');

%stage3, train with residual of stage2
LSF_CB_754_4 = codeBookTrain(residStage2, stage3_b);
save('LSF_CB_754b.mat', 'LSF_CB_754_7', 'LSF_CB_754_5', 'LSF_CB_754_4');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage2(i,:), LSF_CB_754_4);
    [value, idx] = min(distance);
    VQ3(i) = idx;
    residStage3(i,:) = residStage2(i,:) - LSF_CB_754_4(idx,:);  
end
disp('LSF_754b completed');
save('LSF_754b.mat');
