function [S,E,win_pos] =  CepsAna (a,lift,win,overlap,nfft)
%[S,E,win_pos] =  CepsAna (a,lift,win,overlap,nfft)
%this function calculate the Cepstral envelope and pitch for a samples
%a - sample vector
%lift - liftering coefficient for homomorphic decomposition
%win - window samples or window size (for hanning window)
%overlap - overlap factor
%nfft - fft size (could be >= winlen)
%output:
%S - Spectral Envelope
%E - Pitch (excitation) spectrum
%win_pos - analysis position (sample numbers)

[a, nshift] = shiftdim(a);

if nargin < 2,
    lift = 30;
end
if nargin < 3,
    win = 512;
end
if nargin < 4,
    overlap = 2;
end

%win could be a number, in which case default is hanning, or actual window
%samples need to be provided
if length(win) == 1,
    window = hanning(win,'periodic');
    winlen = win;
else
    window = win(:);
    winlen = length(window);
end

if nargin < 5,
    nfft = winlen;
end

hop = winlen/overlap;
win_pos = [1: hop: length(a) - winlen];
b = zeros (winlen,length(win_pos));
C = zeros (nfft,length(win_pos));
Cp = zeros (nfft,length(win_pos));
Ce = zeros (nfft,length(win_pos));

for i=1:length(win_pos)
   b(:,i) = a(win_pos(i):win_pos(i)+winlen-1).*window;
end


%B = real(ifft(log(abs(fft(b,nfft)+0.00001))));
C = real(ifft(log(abs(fft(b,nfft)))));
% Pitch bins are from 1:lfft-1 and same
Ce = C;
Ce(lift+2:end-lift,:) = 0;
Cp(lift+2:end-lift,:) = C(lift+2:end-lift,:);
S = exp(fft(Ce));
E = exp(fft(Cp));

S = S(1:nfft/2+1,:);
E = E(1:nfft/2+1,:);

