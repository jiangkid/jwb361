clear all;
load('codebook_stage1.mat');% codebook1;
load('codebook_stage2.mat');% codebook2;
load('codebook_stage3.mat');% codebook3;
load('../lsf_testData.mat'); %lsf_all
speechLSF = lsf_all';
[length, codebook_dimen] = size(speechLSF);
stage1 = 7;
stage2 = 5;
stage3 = 4;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, codebook_dimen);

%stage1
for i = 1:length
    distance = pdist2(speechLSF(i,:), codebook1);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = speechLSF(i,:) - codebook1(idx,:);    
end

%stage2
for i = 1:length
    distance = pdist2(residStage1(i,:), codebook2);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - codebook2(idx,:);  
end

%stage3
for i = 1:length
    distance = pdist2(residStage2(i,:), codebook3);
    [value, idx] = min(distance);
    VQ3(i) = idx;
    residStage3(i,:) = residStage2(i,:) - codebook3(idx,:);  
end

SD = zeros(length, 1);
for i = 1:length
    LSF_VQ = codebook1(VQ1(i),:)+codebook2(VQ2(i),:)+codebook3(VQ3(i),:);
    SD(i) = spectral_distortion(speechLSF(i,:), LSF_VQ);
end
mean(SD)
hist(SD, 100)
