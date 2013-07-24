clear all;
load('../TIMIT_MFCC.mat'); % TIMIT_MFCC
k = 2^10;
tStart = tic;%start a timer
[x,esq,j] = kmeanlbg(TIMIT_MFCC,k);
toc(tStart);
mfccCB_10b = x;
save('mfccCB_10b.mat','mfccCB_10b');