[x,fs] = wavread('speech');

win = 320;
hop = win/2;
[S,Res,A,E] = LPCAna(x,win,2,16,512); %320 is 40 msec at 8KHz

close all

% figure
% specgram(x)
% title('original')
% figure
% imagesc(log(abs(S))); axis xy
% title('lpc envelope')
% figure
%if overlap 1
%res = Res(:);
%otherwise
res = OLA(Res,2);

%specgram(res)
%title('lpc residual')

r = 1;
if 1,
    nsamp = size(Res,2)*hop + win;
    f0 = 200;
    ex = buzz(f0,nsamp/r,fs);
else
%Sax excitation
[ex,fs2] = wavread('Sax2.wav');
ex = resample(ex,fs,fs2);
%fs = 8000;
end

ymat = LPCfilter(E,A,ex,win,2);
y = OLA(ymat,2);
soundsc(y,fs)


% same filtering can be done using Stft of ex and spectral envelope S. 
% It is left as an excersize for the reader.