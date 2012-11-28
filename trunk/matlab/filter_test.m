
clc; % clear the command line
clear all; % clear the workspace
%
% system constants
% ---------------
InputFilename = 'chinese_8k.wav'; %change it according to your wave files  
[inspeech, fs, bits] = wavread(InputFilename); % read the wavefile
frameIdx = 6;
frameLen = 200;
current_frame = inspeech(frameLen*(frameIdx-1)+1:frameLen*frameIdx);
subplot(221);
plot(current_frame);
grid on;

nfft = 2^nextpow2(length(current_frame));
frame_fft=fft(current_frame, nfft);
mag = abs(frame_fft(1:nfft/2));% 
f = (0:length(mag)-1)'*fs/length(mag)/2;
subplot(223);
plot(f,mag);
grid on;

% 
Wp = 700/fs; Ws = 1400/fs;
[n,Wn] = buttord(Wp, Ws, 2, 30);
[b,a] = butter(n,Wn);
frame_filterd = filter(b, a, current_frame);

subplot(222);
plot(frame_filterd);
grid on;

frame_fft=fft(frame_filterd, nfft);
mag = abs(frame_fft(1:nfft/2)); 
f = (0:length(mag)-1)'*fs/length(mag)/2;
subplot(224);
plot(f,mag);
grid on;

% 
frame_smoothed = smooth(frame_filterd, 7);
figure(2);
subplot(222);
plot(frame_smoothed);
grid on;

frame_fft=fft(frame_smoothed, nfft);
mag = abs(frame_fft(1:nfft/2));% 
f = (0:length(mag)-1)'*fs/length(mag)/2;
subplot(224);
plot(f,mag);
grid on;

