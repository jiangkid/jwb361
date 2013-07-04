function out = instfgram(x,fs,Nfft,overlap)
% out = instfgram(x,fs,Nfft)
% Interactive applications that allows to read the instanteneous
% frequency by clicking a spectrogram.
% x - input sound file
% fs - sampling frequency
% Nfft - fft analysis
%
% Stft analysis is done with overlap 4. 

if nargin == 1,
    fs = 2;
    Nfft = 512;
    overlap = 4;
elseif nargin == 2,
    Nfft = 512;
    overlap = 4;
elseif nargin == 3,
    overlap = 4;
end

tic
[a,f,t] = Instf(x,fs,Nfft,overlap);
toc

Freq = [0:Nfft/2-1]/Nfft*fs;

imagesc(t,Freq,20*log10(a))
axis xy
xlabel('time')
ylabel('frequency')

out = zeros(1,5);
k = 1;
i = 1; 
j=1;
txthandle = [];

while 1,
    [gt,gf,button] = ginput(1);
    
    if isempty(button) | button ~= 1,
        return
    else
        if ~isempty(txthandle),
            set(txthandle,'String',[])
        end
        i = ceil(gf*Nfft/fs);
        j = min(find(t > gt));
        sprintf('i: %d, j: %d, time: %3.2f, , frequency: %3.2f, amplitude (db): %3.2f',i,j, t(j) , f(i,j), 20*log10(a(i,j)))
        out(k,:) = [i j t(j) f(i,j) a(i,j)];
        if gt > t(1) & gt < t(end) & gf > Freq(1) & gf < Freq(end),
            txthandle = text(gt, gf, [num2str(t(j)) ', ' num2str(f(i,j),'%3.2f') ' (bin:' num2str(gf,'%3.2f') '), ' num2str(20*log10(a(i,j)))]);
        end
        k = k+1;
    end
end
