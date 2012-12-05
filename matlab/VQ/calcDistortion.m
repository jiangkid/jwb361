clear all;
load('codebook.mat');
load('../lsf_all.mat'); %lsf_all
speechLSF = lsf_all';
length = size(speechLSF, 1);

%Vector Quantization
VQ = zeros(length, 1);
for i = 1:length
    distance = pdist2(speechLSF(i,:), codebook);
    [minDist,idx] = min(distance);
    VQ(i) = idx;
end

%calculate distortion
SD = zeros(length, 1);
for i = 1:length
    SD(i) = spectral_distortion(speechLSF(i,:), codebook(VQ(i),:));
end