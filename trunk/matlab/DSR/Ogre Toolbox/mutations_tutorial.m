% The process of mutation consists of analysing two sounds by Stft and then
% creating a new hybrid Stft from parts of the original ones. In order to
% capture different properties of the two sounds, we might want to use
% different analysis parameters, specifically using different frequency
% resolutions, or so called using narrow-band v.s. wideband analyses. The
% idea behind different resolutions is that narrowband reveals the detaled
% spectrum, showing the individual partials, which is good for purpose of
% time stretching (the phase vocoder algorithms assumes that every bin
% contains not more the one sinusoid). On the other hand, one might not
% want to use the detailed spectrum when modulating or controlling
% another signal. For example, speech formant are best described using 
% rough spectral characteristics that are revealed through wideband
% analysis.
% In order to perform mutations between Stfts that have different window
% sizes, the following should be done:
% - nffts in both analyses should match (this makes same number of rows in 
% both fft matrices)
% - fft matrix of one of the sounds should be interpolated so that it has
% the same number of columns as fft matrix of the other sound. 
% - in the resynthesis (IStft), a new overlap needs to be determined. This
% overlap should be the original window size divided by the new hop size. 
% For instance, if we analyse sound y with window size wy and for
% restynthesis we use hop that comes from x, i.e. hopx, then in terms of
% the new overlap (the parameter that needs to be provided to IStft)
% becomes wy/hopx.

[x,fs]=wavread('speech.wav');
[y,fs]=wavread('jungle.wav');

close all

wx = 64;
wy = 512;
nfft = wy;
ovx = 2;
ovy = 4;
hopx = wx/ovx;
hopy = wy/ovy;

X = Stft(x,wx,ovx,nfft);
imagesc(log(abs(X)+eps)), axis xy

Y = Stft(y,wy,ovy,nfft);
figure
imagesc(log(abs(Y)+eps)), axis xy
 
[rowx,colx] = size(X);
[rowy,coly] = size(Y);

r = coly/colx;
%T1 = [1:r:coly]; %the new time vector

T1 = linspace(1,coly,colx);

hopy1 = hopx; %if we want Y1 to be same duration as X, hopy1 should be same as hopx.
ovy1 = wy/hopy1; %since the window size of y is different, the new hop size means different overlap.

Y1 = pvinterp(Y,T1,hopy); %phase interpolation using phase vocoder method
y1 = IStft(Y1,ovy1); 


figure
imagesc(log(abs(Y1)+eps)), axis xy
soundsc(y1,fs)

pause

%Moving convolution
Z = X.*Y1;
z = IStft(Z,ovy1);
soundsc(z,fs)

pause

%Crossings: Amplitude envelope of X and original Y (stretched)
U = abs(X).*Y1;
u = IStft(U,ovy1);
soundsc(u,fs)

pause

% Aplitude of X and phases of Y
V = abs(X).*Phasor(Y1);
v = IStft(V,ovy1);
soundsc(v,fs)

% Amplitude of Y and phases of X
Q = abs(Y1).*Phasor(X);
q = IStft(Q,ovy1);
soundsc(q,fs)

