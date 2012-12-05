clear all;
load('../lsf_all.mat'); %lsf_all
train_signal = lsf_all';
[signal_num, codebook_dimen] = size(train_signal);
codebook_size_b = 10; %size 2^10 = 1024
e = 0.01;
k1 = 1+e;
k2 = 1-e;
%initial codebook, by random select data from train signal
%codebook = codeBookInit(train_signal, codebook_size, codebook_dimen);

%codebook train, by split
centroid = sum(train_signal)./signal_num;
codebook = centroid;
tStart = tic;%start a timer
for splitCount = 1 : codebook_size_b
    codebook_split = zeros(2^splitCount, codebook_dimen);%生成空码本
    sizeNow = size(codebook,1);
    %分裂
    for i = 1 : sizeNow
        codebook_split(2*i, :) = k1*codebook(i, :);
        codebook_split(2*i-1, :) = k2*codebook(i, :);
    end
    codebook = codebook_split;
    codebook = LBG(codebook, train_signal);
end
toc(tStart)
save('codebook_10b_split.mat', 'codebook');