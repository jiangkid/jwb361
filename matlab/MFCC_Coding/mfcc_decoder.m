function [sig_r] = mfcc_decoder(mfcc_data_idx)
%
n = 256;
J = 60;
fs = 8000;
[frameNum, col] = size(mfcc_data_idx);

%反量化
mfcc_data = zeros(frameNum, 60);
for frameIdx = 1:frameNum
    mfcc_data(frameIdx,:)  = mfcc_vq_d( mfcc_data_idx(frameIdx,:) );
end

%recover magnitude
[m,a,b]=melbankm(J,n,fs,0,0.5,'y');
mag_r = exp(irdct(mfcc_data.'));
m_MP = pinv(full(m)); % Moore-Penrose pseudoinverse
mag_r = m_MP * mag_r;

%%recover signal
win = hamming(n,'periodic');%256是最佳！
overlap = 2;
[sig_r,] = LSEE(mag_r,win,overlap);

end
