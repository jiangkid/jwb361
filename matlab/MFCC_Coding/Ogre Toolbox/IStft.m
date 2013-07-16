function [a,win_pos] =  IStft (B,overlap,winlen)
% a =  IStft (B,overlap,winlen)
%this function calculate the inverse STFT for a STFT matrix
%B - STFT matrix (bins 1:nfft/2+1)
%overlap - overlap factor (2 => 50%, 4 => 25% and so on).
%winlen - window length (could be <= then nfft)

B = [B; conj(B(end-1:-1:2,:))];

if nargin < 2,
    overlap = 2;
end
if nargin < 3,
    winlen = size(B,1);
end

bmat = ifft(B);
%STFT = real(ifft(B));
hop = winlen/overlap;

[M N] = size(bmat);
nfft = M;

a = zeros (1,N*hop + nfft);
win_pos = [1: hop: length(a) - nfft];
w2 = hanning(winlen,'periodic'); %second smoothing window

for i=1:length(win_pos)
   a(win_pos(i):win_pos(i)+nfft-1) = a(win_pos(i):win_pos(i)+nfft-1) + bmat(:,i)'.*w2';
   %a(win_pos(i):win_pos(i)+nfft-1) = a(win_pos(i):win_pos(i)+nfft-1) + bmat(:,i)';
end

%a = a / nfft;
a = real(a)/overlap*2;

