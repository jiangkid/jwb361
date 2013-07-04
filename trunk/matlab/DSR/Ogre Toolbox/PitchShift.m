function xr = PitchShift(x,r)

X = Stft(x,512,4);
t = [1:r:size(X,2)];
%t = linspace(1,size(X,2),size(X,2)/r);
hop = 512/4;
Xi = pvinterp(X,t,hop);
xi = IStft(Xi,4);
xr = interp1([1:length(xi)],xi,[1:1/r:length(xi)]); %this is not "ideal" interpolation
