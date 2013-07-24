function [ mfcc_data_idx ] = mfcc_vq( mfcc_data )
%MFCC_VQ: mfcc split vertor quantization
%  8, 10, 10, 10
global block1_CB block2_CB block3_CB block4_CB

mfcc_data_idx = zeros(1,4);
%1:5
distance = pdist2(mfcc_data(1:5), block1_CB);
[value, idx] = min(distance);
mfcc_data_idx(1) = idx;

%6:20
distance = pdist2(mfcc_data(6:20), block2_CB);
[value, idx] = min(distance);
mfcc_data_idx(2) = idx;

%21:40
distance = pdist2(mfcc_data(21:40), block3_CB);
[value, idx] = min(distance);
mfcc_data_idx(3) = idx;

%41:60
distance = pdist2(mfcc_data(41:60), block4_CB);
[value, idx] = min(distance);
mfcc_data_idx(4) = idx;

end

