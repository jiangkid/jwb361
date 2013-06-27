clear all;
clc;
[speech, fs] = wavread('part2.wav');
c = melcepst(speech,fs);