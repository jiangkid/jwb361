close all;
clear all;
fileName = '../corpus/TIMIT_dr1_8k.wav';%TIMIT_dr1_8k.wav
J = 70;
n = 256;

[inSpeech, fs, bits] = wavread(fileName);
TIMIT_MFCC = mfcc(inSpeech, fs, 'My', J, J, n);
% stem(mean(TIMIT_MFCC));
% stem(var(TIMIT_MFCC));
TIMIT_MFCC = TIMIT_MFCC';
save('TIMIT_MFCC.mat', 'TIMIT_MFCC');