%Least-Squares Estimate (LSE), Inverse Short-Time Fourier Transform Magnitude (ISTFTM).
%已知傅里叶幅度，估计相位，恢复信号
clc; % clear the command line
clear all; % clear the workspace
close all;

InputFilename = 'part2.wav';
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
inSpeech = inSpeech*32767;
frameLen = 180;
delta = 1;
frameNum = length(inSpeech)/frameLen;
b = max(inSpeech);
a = max(inSpeech);
outSpeech = zeros(1,frameNum*frameLen);
M = 100;
HammingW = hamming(frameLen);
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);    
    %加窗hamming
    %frameData = frameData.*HammingW;
    dataFFT = fft(frameData, 256);
    dataAmp = abs(dataFFT);
    dataAngle = angle(dataFFT);
%     subplot(321);
%     plot(frameData);
%     subplot(323);
%     plot(dataAmp);
%     subplot(325);
%     plot(dataAngle);
    
    data_r = a + (b-a).*rand(frameLen,1);%reconstruct
    for i = 1:M
        fft_r = fft(data_r, 256);
        amp_r = abs(fft_r);
        angle_r = angle(fft_r);
        
        fft_r = dataAmp.*exp(1i*angle_r);
        iData = ifft(fft_r);
        data_r = real(iData(1:180));
        
%         subplot(322);
%         plot(data_r);
%         title(i);
%         subplot(324);
%         plot(amp_r);
%         subplot(326);
%         plot(angle_r);
    end
    outSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx) = data_r;
end
% soundsc(outSpeech, 8000);
wavwrite(outSpeech/32768, 8000, strcat(datestr(now,'HH_MM_SS'),'.wav'));
