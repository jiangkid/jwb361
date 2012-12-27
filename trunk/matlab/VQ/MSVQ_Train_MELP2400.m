%MELP600Âë±¾ÑµÁ·
clear all;
load('../lsf_all.mat'); %lsf_all
train_signal = lsf_all';
train_signal = 4000*train_signal/pi;%
[length, codebook_dimen] = size(train_signal);
stage1_b = 7;
stage2_b = 6;
stage3_b = 6;
stage4_b = 6;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, codebook_dimen);
VQ4 = zeros(length, 1);
residStage4 = zeros(length, codebook_dimen);

%stage1, train with origin signal
codebook1 = codeBookTrain(train_signal, stage1_b);
save('codebook_stage1.mat', 'codebook1');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), codebook1);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - codebook1(idx,:);    
end
disp('stage1 completed');
save('stage1.mat');

%stage2, train with residual of stage1
codebook2 = codeBookTrain(residStage1, stage2_b);
save('codebook_stage2.mat', 'codebook2');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), codebook2);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - codebook2(idx,:);  
end
disp('stage2 completed');
save('stage2.mat');

%stage3, train with residual of stage2
codebook3 = codeBookTrain(residStage2, stage3_b);
save('codebook_stage3.mat', 'codebook3');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage2(i,:), codebook3);
    [value, idx] = min(distance);
    VQ3(i) = idx;
    residStage3(i,:) = residStage2(i,:) - codebook3(idx,:);  
end
disp('stage3 completed');
save('stage3.mat');

%stage4, train with residual of stage3
codebook4 = codeBookTrain(residStage3, stage4_b);
save('codebook_stage4.mat', 'codebook4');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage3(i,:), codebook4);
    [value, idx] = min(distance);
    VQ4(i) = idx;
    residStage4(i,:) = residStage3(i,:) - codebook4(idx,:);  
end
disp('stage4 completed');
save('stage4.mat');
