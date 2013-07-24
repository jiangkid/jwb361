%split vector quantization
clear all;
load('../TIMIT_MFCC.mat'); % TIMIT_MFCC
dataLen = length(TIMIT_MFCC);

block1_k = 2^9; %dim 2~5
block2_k = 2^9; %dim 6~14
block3_k = 2^9; %dim 15~30
block4_k = 2^7; %dim 30~60

block1_data = TIMIT_MFCC(:,2:5); 
block2_data = TIMIT_MFCC(:,6:14); 
block3_data = TIMIT_MFCC(:,15:30); 
block4_data = TIMIT_MFCC(:,30:60);

tStart = tic;%start a timer
[block1_CB,esq,j] = kmeanlbg(block1_data,block1_k);
[block2_CB,esq,j] = kmeanlbg(block2_data,block2_k);
[block3_CB,esq,j] = kmeanlbg(block3_data,block3_k);
[block4_CB,esq,j] = kmeanlbg(block4_data,block4_k);

toc(tStart);%1381

save('mfccCB_9997.mat','block1_CB','block2_CB','block3_CB','block4_CB');
