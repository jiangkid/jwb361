function PESQ = mfcc2signal(fileName, J)
%fileName, J: Mel-fileter bank
[inSpeech, fs, bits] = wavread(fileName); % read the wavefile

n = 256; % n, length of frame in samples (default power of 2 < (0.03*fs))
c = mfcc(inSpeech, fs, 'My', J, J, n);

%recover magnitude
[m,a,b]=melbankm(J,n,fs,0,0.5,'y');
mag_r = exp(irdct(c.'));
m_MP = pinv(full(m)); % Moore-Penrose pseudoinverse 
mag_r = m_MP * mag_r;

%%recover signal
win = hamming(n,'periodic');%256ÊÇ×î¼Ñ£¡
overlap = 2; 
[sig_r,] = LSEE(mag_r,win,overlap);
% subplot('Position',[0.05 0.55 0.93 0.45]);
% mesh(m);
% subplot('Position',[0.05 0.05 0.93 0.49]);
% mesh(c');
pesq_out = pesqbin(inSpeech, sig_r, fs, 'nb');
PESQ = pesq_out(1);