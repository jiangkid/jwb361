function xi = TimeStretch(x,r)

X = Stft(x,512,4);
t = [1:r:size(X,2)-1];
%t = linspace(1,size(X,2),size(X,2)/r);
hop = 512/4;
Xi = pvinterp(X,t,hop);
xi = IStft(Xi,4);

%win = hanning(512,'periodic');
%xi = IStftw2(Xi,2,win);