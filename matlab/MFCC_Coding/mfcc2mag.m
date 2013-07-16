clear all;
clc;
[speech, fs] = wavread('si2323_8k.wav');

nc = 12; % nc, number of cepstral coefficients excluding 0'th coefficient (default 12)
p = 70;  % p, number of filters in filterbank (default: floor(3*log(fs)) = approx 2.1 per ocatave)
n = 256; % n, length of frame in samples (default power of 2 < (0.03*fs))
c = mfcc(speech, fs, 'My', nc, p, n);

[m,a,b]=melbankm(p,n,fs,0,0.5,'y');

%reconstruct
y_r = exp(irdct(c.'));
m_MP = pinv(full(m)); % Moore-Penrose pseudoinverse 
y_r = m_MP * y_r;
% subplot('Position',[0.05 0.55 0.92 0.44]);
% mesh(abs(f(a:b,:)));
% subplot('Position',[0.05 0.05 0.92 0.44]);
mesh(abs(y_r));
save('y_r.mat', 'y_r');

