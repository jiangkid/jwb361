clear;
fileName = '../corpus/dr1-faks0/wav_8k/dr1-faks0.wav';
[inSpeech, fs, bits] = wavread(fileName); % read the wavefile

J = 60;
n = 256; % n, length of frame in samples (default power of 2 < (0.03*fs))
mfcc_data = mfcc(inSpeech, fs, 'My', J, J, n);

%Á¿»¯
global block1_CB block2_CB block3_CB block4_CB;
load('./mfccCB.mat');%block1_CB£¬block2_CB£¬block3_CB£¬block4_CB
[frameNum,col] = size(mfcc_data);
mfcc_data_idx = zeros(frameNum, 4);

for frameIdx = 1:frameNum
    mfcc_data_idx(frameIdx,:) = mfcc_vq(mfcc_data(frameIdx,:));
end
% save('mfcc_data_vq.mat', mfcc_data_vq);
outSpeech = mfcc_decoder(mfcc_data_idx);
pesq_out = pesqbin(inSpeech, outSpeech, fs, 'nb')


