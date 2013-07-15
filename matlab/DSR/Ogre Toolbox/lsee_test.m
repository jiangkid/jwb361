% clc; % clear the command line
clear all; % clear the workspace
close all;

InputFilename = '../mbma1.wav';
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
win = hamming(256,'periodic');%256ÊÇ×î¼Ñ£¡
overlap = 2; 
Y = Stft(inSpeech,win,overlap);
Y = abs(Y);
[rec,D] = LSEE(Y,win,overlap);
pesqbin(inSpeech, rec, fs, 'nb')
