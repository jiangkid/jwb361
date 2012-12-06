%clear all;
%load('../lsf_all.mat'); %lsf_all
%train_signal = lsf_all';
%size_b = 10; %size 2^10 = 1024
function codebook = codeBookTrain(train_signal, size_b)
[signal_num, codebook_dimen] = size(train_signal);
e = 0.01;
k1 = 1+e;
k2 = 1-e;
tStart = tic;%start a timer
disp('codeBookTrain');

%initial codebook, 随机选择法，方法简单，但量化器性能较差
%codebook = codeBookInit(train_signal, codebook_size, codebook_dimen);

%codebook train, 分裂法，算法复杂，但量化器性能好
centroid = sum(train_signal)./signal_num;
codebook = centroid;
for splitCount = 1 : size_b
    codebook_split = zeros(2^splitCount, codebook_dimen);%生成空码本
    sizeNow = size(codebook,1);
    %分裂
    for i = 1 : sizeNow
        codebook_split(2*i, :) = k1*codebook(i, :);
        codebook_split(2*i-1, :) = k2*codebook(i, :);
    end
    codebook = codebook_split;
    codebook = LBGFun(codebook, train_signal);
end

%codebook refine，剔除非典型胞腔
codebook = codeBookRefine(codebook, train_signal);

toc(tStart)
%save('codebook_10b_split.mat', 'codebook');
