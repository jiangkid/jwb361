% ∏¡ø¡øªØ≤‚ ‘
clear;
global block1_CB block2_CB block3_CB block4_CB;
load('./mfccCB.mat');%block1_CB£¨block2_CB£¨block3_CB£¨block4_CB

load('./TIMIT_MFCC_test.mat');
mfcc_data = TIMIT_MFCC_test;
dataLen = length(mfcc_data);
mfcc_data_idx = zeros(dataLen, 4);
mfcc_data_d = zeros(dataLen, 60);
residual = zeros(1, dataLen);
%Vector Quantization
vq_err = 0;
for i = 1: dataLen
    mfcc_data_idx(i,:) = mfcc_vq( mfcc_data(i,:) ); 
end
%de-
for i = 1: dataLen
    mfcc_data_d(i,:) = mfcc_vq_d( mfcc_data_idx(i,:) ); 
end
for i = 1: dataLen
    err = sqrt(sum(abs(mfcc_data(i,:) - mfcc_data_d(i,:)).^2));
    vq_err = vq_err+err;
end
disp(vq_err/dataLen);
