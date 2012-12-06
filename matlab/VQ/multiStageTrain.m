clear all;
load('../lsf_all.mat'); %lsf_all
train_signal = lsf_all';
[length, codebook_dimen] = size(train_signal);
stage1 = 7;
stage2 = 5;
stage3 = 4;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, 1);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, 1);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, 1);

%stage1, train with origin signal
codebook1 = codeBookTrain(train_signal, stage1);
save('codebook_stage1.mat', 'codebook1');
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), codebook1);
    [residStage1(i), VQ1(i)] = min(distance);
end
disp('stage1 completed');
save('stage1.mat');

%stage2, train with residual of stage1
codebook2 = codeBookTrain(residStage1, stage2);
save('codebook_stage2.mat', 'codebook2');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), codebook2);
    [residStage2(i), VQ2(i)] = min(distance);
end
disp('stage2 completed');
save('stage2.mat');

%stage3, train with residual of stage2
codebook3 = codeBookTrain(residStage2, stage3);
save('codebook_stage3.mat', 'codebook3');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage2(i,:), codebook21);
    [residStage3(i), VQ3(i)] = min(distance);
end
disp('stage3 completed');
save('stage3.mat');
