clc; % clear the command line
clear all; % clear the workspace
% ---------------
[b_2k, a_2k] = butter(4, 0.5);
[b_4k, a_4k] = butter(4, 0.9999);

InputFilename = 'part2.wav'; %change it according to your wave files  
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
inSpeech = inSpeech*32767;
frameLen = 180;
delta = 1;
frameNum = length(inSpeech)/frameLen;
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);
    
    frame_fft_4k = fft(frameData, 256);
    plot((1:128)./128, abs(frame_fft_4k(1:128)));
    grid on;
    hold on;
    
    frame_fft_2k = fft(frameData(1:2:frameLen), 256);
    plot((1:128)./256, abs(frame_fft_2k(1:128)), 'r');
    
    frameData_filter = filter(b_2k, a_2k, frameData);
    frameDataDown = frameData_filter(1:2:frameLen);
    frame_fft_2k = fft(frameDataDown, 256);
    plot((1:128)./256, abs(frame_fft_2k(1:128)), 'g'); 
    
    frameDataUp(1:frameLen) = 0;
    frameDataUp(1:2:frameLen) = frameDataDown;
    frameDataUp_fft = fft(frameDataUp, 256);
    plot((1:128)./128, abs(frameDataUp_fft(1:128)), 'black'); 
    
    hold off;
    
    figure(2);
    frameDataUp_filter = filter(b_2k, a_2k, frameDataUp);
    frameDataUp_filter_fft = fft(frameDataUp_filter, 256);
    plot(abs(frameDataUp_filter_fft)); 
    pause;
end
speech_4k = inSpeech(1:2:length(inSpeech));
soundsc(speech_4k,4000);