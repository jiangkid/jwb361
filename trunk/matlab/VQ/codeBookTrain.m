clear all;
load('../lsf_all.mat'); %lsf_all
train_signal = lsf_all';
[signal_num, codebook_dimen] = size(train_signal);
codebook_size = 2^4; %
codebook = codeBookInit(train_signal, codebook_size, codebook_dimen);
tStart = tic;%start a timer

codebook = LBG(codebook, train_signal);

toc(tStart)
%save('codebook_10b_split.mat', 'codebook');