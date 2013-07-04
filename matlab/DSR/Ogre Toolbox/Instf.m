function [a,f,t,p] = Instf(x,fs,Nfft,overlap)
% [a,f,t,p] = Instf(x,fs,Nfft)
% Instanteneous Frequency using hanning window and hop 1 method
% input:
% x - input sound
% f - sampling frequency
% Nfft - fft size, equal to window size
% overlap - overlap factor (2 means 50%, 4 means 75%)
% output:
% a - amplitude
% f - instanteneous frequency
% t - time
% p - phasor (fft with unit magnitude)

if nargin < 3,
    % fft length
    Nfft = 512; %1024;
end
if nargin < 4,
    overlap = 4;
end
x = x(:);

win = ones(Nfft,1);
% Rectangular window STFT analysis. 
% X is of size (k*t) where k is the number of FFT bins and t is number of frames
X = Stft(x,win,overlap);


%% Take only positive frequencies
%X = X(1:Nfft/2+1,:);

% FFT bins
k = [0:Nfft/2]';
%k = k-(Nfft/2);
f = zeros(size(X));

for i=1:size(X,2),
   
    % one instance of the spectrum
    Xk = X(:,i);
    Xkplus1 = [Xk(2:end);eps];
    Xkminus1 = [eps;Xk(1:end-1)];
    
    % frequency estimation (hop one trick)
    f(:,i) = fs*(k./Nfft - imag((j/Nfft).*((Xkplus1-Xkminus1)./(2*Xk-Xkplus1-Xkminus1+2*eps))));
    % current time
    t(i) = i*((Nfft/4)/fs);
    
end

win = hanning(Nfft,'periodic');
X1 = Stft(x,win,overlap);
a = abs(X1);
p = X1./a;
