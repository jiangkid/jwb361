function Ph = Phasor(X,dyn);
% Ph = Phasor(X,dyn);
% Calculates a complex phasor of an STFT Matrix
% dyn = desigred dynamic range (0 default)
%
% Note that Phasor performs dynamic range compression in frequency.

if nargin < 2,
    dyn = 0; %40dB
end

%Ph = exp(sqrt(-1)*angle(X))
Mag = abs(X);
Ph = X./abs(X);

Mmin = min(min(Mag));
Mmax = max(max(Mag));
d1 = 10*log10(Mmax/Mmin);
Scale = 10^((dyn-d1)/10);

%We scale all Mag above Mmin by Scale.
Mag = (Mag-Mmin)*Scale + Mmin;
Ph = Mag.*Ph;

