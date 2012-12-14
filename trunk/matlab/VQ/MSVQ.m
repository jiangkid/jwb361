clear all;
load('codebook_stage1.mat');% codebook1;
load('codebook_stage2.mat');% codebook2;
load('codebook_stage3.mat');% codebook3;
load('../lsf_all.mat'); %lsf_all
speechLSF = lsf_all';
length = size(speechLSF, 1);
stage1 = 7;
stage2 = 5;
stage3 = 4;

%stage1
VQ1 = zeros(length, 1);
residStage1 = zeros(length, 1);
for i = 1:length
    distance = pdist2(speechLSF(i,:), codebook1);
    [residStage1(i), VQ1(i)] = min(distance);
    VQ1(i) = idx;
end

%stage2
VQ2 = zeros(length, 1);
residStage2 = zeros(length, 1);
for i = 1:length
    distance = pdist2(residStage1(i,:), codebook2);
    [residStage2(i), VQ2(i)] = min(distance);
    VQ2(i) = idx;
end

%stage3
VQ3 = zeros(length, 1);
residStage3 = zeros(length, 1);
for i = 1:length
    distance = pdist2(residStage1(i,:), codebook3);
    [residStage3(i), VQ3(i)] = min(distance);
    VQ3(i) = idx;
end

SD = zeros(length, 1);
for i = 1:length
    SD(i) = spectral_distortion(speechLSF(i,:), codebook(VQ(i),:));
end
mean(SD)
hist(SD, 100)
