%split vector quantization
clear all;
load('../TIMIT_MFCC.mat'); % TIMIT_MFCC
dataLen = length(TIMIT_MFCC);

block1_k = 2^8; %dim 1~5
block2_k = 2^10; %dim 6~20
block3_k = 2^10; %dim 21~40
block4_k = 2^10; %dim 41~60

block1_data = TIMIT_MFCC(:,1:5); %dim 1~5
block2_data = TIMIT_MFCC(:,6:20); %dim 6~20
block3_data = TIMIT_MFCC(:,21:40); %dim 21~40
block4_data = TIMIT_MFCC(:,41:60); %dim 41~60

tStart = tic;%start a timer
[block1_CB,esq,j] = kmeanlbg(block1_data,block1_k);
[block2_CB,esq,j] = kmeanlbg(block2_data,block2_k);
[block3_CB,esq,j] = kmeanlbg(block3_data,block3_k);
[block4_CB,esq,j] = kmeanlbg(block4_data,block4_k);

toc(tStart);%3987

save('mfccCB.mat','block1_CB','block2_CB','block3_CB','block4_CB');
