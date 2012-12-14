%∆µ”Ú¬À≤®
clc; % clear the command line
clear all; % clear the workspace
% ---------------

InputFilename = 'part2.wav'; %change it according to your wave files
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
inSpeech = inSpeech*32767;
frameLen = 180;
frameNum = length(inSpeech)/frameLen;
[b, a]=butter(6, 1000/4000);
[h, w] = freqz(b,a, 256);
%subplot(211);
%plot(w/pi,abs(h));
%subplot(212);
%plot(w/pi,20*log10(abs(h)));
d = 1:180;
f = 0:255;
f = f/256;
v1 = zeros(length(inSpeech), 1);
v2 = zeros(length(inSpeech), 1);
dataFreqAngle = zeros(512, 1);
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);
    % ±”Ú
    dataOut = filter(b, a, frameData);
    dataOutfft = fft(dataOut, 512);    
    %∆µ”Ú
    dataFreqOut = freq_filter(frameData, abs(h));
    %plot(f, abs(frameDatafft(1:256)), 'r', f, abs(dataOutfft(1:256)), 'b', f, dataFreq, '*-g');
    %plot(d,dataOut, 'r', d, dataFreqOut,'g');
    v1(frameLen*(frameIdx-1)+1 : frameLen*frameIdx) = dataOut;
    v2(frameLen*(frameIdx-1)+1 : frameLen*frameIdx) = dataFreqOut;
end
soundsc(v1, fs);
soundsc(v2, fs);
