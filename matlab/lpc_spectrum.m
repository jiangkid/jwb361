
clc; % clear the command line
clear all; % clear the workspace
% ---------------
methodType  = 2;%方法1，利用FFT；方法2，直接计算；方法3，利用频率响应函数freqz

InputFilename = 'part2.wav'; %change it according to your wave files  
[inSpeech, fs, bits] = wavread(InputFilename); % read the wavefile
inSpeech = inSpeech*32767;
frameLen = 180;
delta = 1;
frameNum = length(inSpeech)/frameLen;
for frameIdx = 1:frameNum
    frameData = inSpeech(frameLen*(frameIdx-1)+1 : frameLen*frameIdx);
    figure(9);
    %fft analysis
    framefft = fft(frameData, 512);    
    framefftData = abs(framefft(1:256).^2)/512;
    framefftData = 10*log10(framefftData);
    f = 0:1/256:1;
    %lpc analysis
    [framelpc_a, framelpc_g] = lpc(frameData, 20);
    if methodType == 1
        %method 1, by fft        
        lpc_fft = fft(framelpc_a, 512);
        plotData = framelpc_g./abs(lpc_fft(1:256).^2);
    elseif methodType == 2
        %method 2, 计算频率响应        
        for j=1:256
            w(j) = exp(-1i*f(j)*pi*(1:20))*framelpc_a(2:21)';
        end        
        plotData = framelpc_g./(abs(1+w).^2);
    elseif methodType == 3
        %method 3, freqz
        [h, ff] = freqz(sqrt(framelpc_g), framelpc_a, 256);
        ff = ff/pi;
        plotData = abs(h).^2;
    end
    plotData = 10*log10(plotData);    
    plot(f(1:256), framefftData, f(1:256), plotData, 'r');
    grid on;
    pngName = sprintf('LPC_Spctrum%d.png',frameIdx);
    print(gcf,'-dpng', pngName);
end
