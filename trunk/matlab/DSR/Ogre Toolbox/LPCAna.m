function [S,Res,A,E,win_pos] =  LPCAna (a,win,overlap,p,nfft)
%[S,Res,A,E,win_pos] =  LPCAna (a,win,overlap,p,nfft)
%this function calculates the LPC analysis for a samples
%a - sample vector
%win - window size (for rectangular window) or actual window samples
%overlap - overlap factor
%p - lpc order
%nfft - LPC spectrum resolution (fft bins)
%output:
%S - Spectral Envelope
%Res - Pitch (excitation) samples matrix.
%A - LPC coefficients
%E - LPC error
%win_pos - analysis position (sample numbers)

[a, nshift] = shiftdim(a);

if nargin < 2,
    win = 512;
end

%win could be a number, in which case default is hanning, or actual window
%samples need to be provided
if length(win) == 1,
    window = ones(win,1);
    winlen = win;
else
    window = win(:);
    winlen = length(window);
end

if nargin < 3,
    overlap = 2;
end
if nargin < 4,
    p = 10;
end
if nargin < 5,
    nfft = winlen;
end

hop = winlen/overlap;
N = floor(nfft/2) + 1;
win_pos = [1: hop: length(a) - winlen];
b = zeros (winlen,length(win_pos));
A = zeros (p,length(win_pos));
E = zeros (1,length(win_pos));
S = zeros (N,length(win_pos));
Res = zeros(size(b));


for i=1:length(win_pos)
   b(:,i) = a(win_pos(i):win_pos(i)+winlen-1).*window;
end

[A,E] = lpc(b,p);

%return value
% lpc specgram
z = zeros(1,p); %initial filter conditions
for i = 1:size(A,1),
S(:,i) = freqz(E(i),A(i,:),N)';
Res(:,i) = filter(A(i,:),1,b(:,i));
%[Res(:,i),z] = filter(A(i,:),E(i),b(:,i),z);
%Res(:,i) = filter(A(i,:),E(i),b(:,i));
end
