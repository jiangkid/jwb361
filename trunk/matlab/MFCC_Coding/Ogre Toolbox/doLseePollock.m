A = imread('Pollock.jpg');
fs = 11025;

Y = double(A(1:end,:,1))*1000;
if mod(size(Y,1),2) == 0;
    Y = Y(1:end-1,:);
end
window = hanning((size(Y,1)-1)*2,'periodic');
window_length = length(window);
step_dist1 =  floor(size(Y,1)/2);
overlap = 4; 
[rec,D] = LSEE(Y,window,overlap);

sampling_rate =  (1/fs);
IMGY = window_length;
LENX = length(rec);

figure(2);
subplot(2,1,1);
imagesc([0:(step_dist1*sampling_rate):(sampling_rate*(LENX-1))], ...
        [0:(fs/IMGY/2):fs/2],20*log10(Y(1:IMGY/2,:)));
axis xy

title('STFT Magnitude of Original Signal');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');

Yrec = abs(Stft(rec',window,overlap));

subplot(2,1,2);
imagesc([0:(step_dist1*sampling_rate):(sampling_rate*(LENX-1))], ...
        [0:(fs/IMGY/2):fs/2],20*log10(abs(Yrec(1:IMGY/2,:))+eps));
axis xy

title('STFT Magnitude of Reconstructed Signal');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');

pause

soundsc(rec,fs);
