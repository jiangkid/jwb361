%clear

[x,fs] = wavread('speech');

r = 0.2; %0.5; %75; %0.1; %0.02; %time stretching factor

%Init
win = 512;
overlap = 4;
Nfft = 512;
hop = Nfft/overlap;

X = Stft(x,win,overlap);

% If you do not have stft program
%cnt = 1;
% for i = 0:hop:(length(x)-Nfft)
%   wx = win.*x((i+1):(i+Nfft));
%   WX = fft(wx);
%   X(:,cnt) = WX(1:(1+Nfft/2));
%   cnt = cnt+1;
% end;

[rows, cols] = size(X);
t = 1:r:cols; %time vector (can be non-linear set of time instances)

[X2,iF] = pvinterp(X, t, hop);

x2 = IStft(X2,overlap);
soundsc(x2,fs)


