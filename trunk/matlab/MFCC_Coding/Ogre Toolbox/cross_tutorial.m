[y,fs]=wavread('speech.wav');
[x,fs2]=wavread('jungle.wav');
%fs2 = 8000;
%y = sin(2*pi*220*[1:fs2]/fs2);

close all

if fs2 ~= fs,
    warning('Files have different sampling rate');
end


Y = Stft(y);

Ogre = 'Stft'
%Ogre = 'LPC'
%Ogre = 'Welch'
%Ogre = 'Ceps'
switch Ogre,
    case 'Stft'
        X = Stft(x,64,2,512);
        imagesc(log(abs(X))); axis xy
        title(Ogre)
        S = abs(X);
        hop = 32;
        
    case 'LPC'
        %different methods of spectral envelope analysis
        [S,Res] = LPCAna(x);
        imagesc(log(abs(S))); axis xy
        title(Ogre)
        hop = 256;

    case 'Welch'
        S = WelchAna(x);
        imagesc(log(abs(S))); axis xy
        title(Ogre)
        hop = 256;
        
    case 'Ceps'
        [S,E] = CepsAna(x,10);
        subplot(211)
        imagesc(log(abs(S))); axis xy
        subplot(212)
        imagesc(log(abs(E))); axis xy
        hop = 256;
end


%different alignments (modulator to source or source to modulator)
Yi = pvalign(Y,S,hop);
Z = S.*Phasor(Yi);
%%yr = Istft(abs(Yi).*Phasor(Yi));
%yr = IStft(abs(Yi).*Phasor(Yi,0.1));

%Si = specalign(S,Y);
%Z = Si.*Phasor(Y);
z = IStft(Z);

soundsc(z,fs)

