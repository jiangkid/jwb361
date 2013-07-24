close all;
clear all;
fileName = '../corpus/dr1-faks0/wav_8k/dr1-faks0.wav';%TIMIT_dr1_8k.wav
J = 60;
n = 256;

[inSpeech, fs, bits] = wavread(fileName);
TIMIT_MFCC_test = mfcc(inSpeech, fs, 'My', J, J, n);
% stem(mean(TIMIT_MFCC));
% stem(var(TIMIT_MFCC_test));
% TIMIT_MFCC = TIMIT_MFCC';
save('TIMIT_MFCC_test.mat', 'TIMIT_MFCC_test');