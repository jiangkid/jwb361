function [Pxx,win_pos] =  WelchAna (a,win,overlap,p,nfft)
%[S,A,res,Win_pos] =  WelchAna (a,winlen,overlap,nfft)
%this function calculate the STFT for a samples
%a - sample vector
%win - window size (for rectangular window) or actual window samples
%p - fraction of window length to be used for subwindows (snapshots) 
%nfft - power spectrum resolution (fft bins)

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
    p = 8;
end
if nargin < 5,
    nfft = winlen;
end

hop = winlen/overlap;

N = floor(nfft/2) + 1;
win_pos = [1: hop: length(a) - winlen];
Pxx = zeros (N,length(win_pos));

for i=1:length(win_pos)
   b = a(win_pos(i):win_pos(i)+winlen-1).*window;
   Pxx(:,i) = pwelch(b,winlen/p,[],nfft);
end


