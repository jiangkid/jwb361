%Least-Squares Estimate (LSE), Inverse Short-Time Fourier Transform Magnitude (ISTFTM).
%已知傅里叶幅度，估计相位，恢复信号
clc; % clear the command line
clear all; % clear the workspace
close all;

InputFilename = 'part2.wav';
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
inSpeech = inSpeech*32767;
frameLen = 240;
delta = 1;
frameNum = fix(length(inSpeech)/frameLen);
b = max(inSpeech);
a = max(inSpeech);
M = 100;
HammingW = hamming(frameLen);

outSpeech = zeros(1,frameLen*frameNum);
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);    
    %加窗hamming
    frameData = frameData.*HammingW;
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
        data_r = real(iData(1:frameLen));
        
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

%帧重叠50%
frameLen_2 = frameLen/2;
frameNum_2 = fix(frameNum*2);
outSpeech_2 = zeros(1,frameLen_2*frameNum_2+frameLen_2);

for frameIdx = 1:frameNum_2
    frameData = inSpeech(frameLen_2*(frameIdx-1)+1 : frameLen_2*(frameIdx-1)+frameLen); %帧重叠50%
    frameData = frameData.*HammingW;
    dataFFT = fft(frameData, 256);
    
    dataAmp = abs(dataFFT);
    data_r = a + (b-a).*rand(frameLen,1);%reconstruct
    for i = 1:M
        fft_r = fft(data_r, 256);
        amp_r = abs(fft_r);
        angle_r = angle(fft_r);
        
        fft_r = dataAmp.*exp(1i*angle_r);
        iData = ifft(fft_r);
        data_r = real(iData(1:frameLen));
    end
    
%     iData = ifft(dataFFT);
%     data_r = real(iData(1:frameLen));
    
    iframeData = outSpeech_2(frameLen_2*(frameIdx-1)+1 : frameLen_2*(frameIdx-1)+frameLen);
    iframeData = iframeData + data_r';
    outSpeech_2(frameLen_2*(frameIdx-1)+1 : frameLen_2*(frameIdx-1)+frameLen) = iframeData;
end
% wavwrite(outSpeech_2/32768, 8000, strcat(datestr(now,'HH_MM_SS'),'.wav'));

soundsc(outSpeech_2, 8000);
soundsc(outSpeech, 8000);
% wavwrite(outSpeech/32768, 8000, strcat(datestr(now,'HH_MM_SS'),'.wav'));
