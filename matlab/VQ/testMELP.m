%测试MELP 2.4k 的LSF矢量量化码本
clear all;
stage;%stage1 stage2
load('../lsf_all.mat'); %lsf_all
speechLSF = lsf_all';
speechLSF = 4000*speechLSF/pi;
[length, codebook_dimen] = size(speechLSF);
codebook1 = zeros(128, codebook_dimen);
codebook2 = zeros(64, codebook_dimen);
codebook3 = zeros(64, codebook_dimen);
codebook4 = zeros(64, codebook_dimen);
for idx = 1:128
    codebook1(idx,:) = stage1(idx*10-9:idx*10);
end
for idx = 1:64
    codebook2(idx,:) = stage2(1,idx*10-9:idx*10);
    codebook3(idx,:) = stage2(2,idx*10-9:idx*10);
    codebook4(idx,:) = stage2(3,idx*10-9:idx*10);
end

VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, codebook_dimen);
VQ4 = zeros(length, 1);
residStage4 = zeros(length, codebook_dimen);

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

%stage4
for i = 1:length
    distance = pdist2(residStage3(i,:), codebook4);
    [value, idx] = min(distance);
    VQ4(i) = idx;
    residStage4(i,:) = residStage3(i,:) - codebook4(idx,:);  
end

speechLSF = pi*speechLSF/4000;
SD = zeros(length, 1);
for i = 1:length
    LSF_VQ = codebook1(VQ1(i),:)+codebook2(VQ2(i),:)+codebook3(VQ3(i),:)+codebook4(VQ4(i),:);
    LSF_VQ = pi*LSF_VQ/4000;
    for k = 1:10
        if LSF_VQ(k) > pi
            LSF_VQ(k) = pi;
        end
        if LSF_VQ(k) < 0
            LSF_VQ(k) =0;
        end
    end
    SD(i) = spectral_distortion(speechLSF(i,:), LSF_VQ);
end
mean(SD)
hist(SD, 100)
