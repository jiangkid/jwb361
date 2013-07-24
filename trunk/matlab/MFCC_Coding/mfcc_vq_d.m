function [ mfcc_data ] = mfcc_vq_d( mfcc_data_idx )
%MFCC_VQ: mfcc split vertor quantization
%  8, 10, 10, 10
global block1_CB block2_CB block3_CB block4_CB

mfcc_data = zeros(1,60);

mfcc_data(1:5) =  block1_CB(mfcc_data_idx(1),:);
mfcc_data(6:20) =  block2_CB(mfcc_data_idx(2),:);
mfcc_data(21:40) =  block3_CB(mfcc_data_idx(3),:);
mfcc_data(41:60) =  block4_CB(mfcc_data_idx(4),:);

end

